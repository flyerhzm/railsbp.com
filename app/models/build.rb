# == Schema Information
#
# Table name: builds
#
#  id                  :integer(4)      not null, primary key
#  warning_count       :integer(4)
#  repository_id       :integer(4)
#  aasm_state          :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  last_commit_id      :string(255)
#  last_commit_message :text
#  position            :integer(4)
#  duration            :integer(4)      default(0)
#  finished_at         :datetime
#  branch              :string(255)     default("master"), not null
#

class Build < ActiveRecord::Base
  include AASM

  belongs_to :repository, :counter_cache => true

  before_create :set_position
  after_destroy :remove_analyze_file

  attr_accessor :warnings
  attr_accessible :branch, :duration, :finished_at, :last_commit_id, :last_commit_message, :position

  scope :completed, where(:aasm_state => "completed")

  aasm do
    state :scheduled, initial: true
    state :running, enter: :analyze
    state :completed
    state :failed

    event :run do
      transitions to: :running, from: :scheduled
    end

    event :complete do
      transitions to: :completed, from: [:running, :scheduled]
    end

    event :fail do
      transitions to: :failed, from: :running
    end

    event :rerun do
      transitions to: :running, from: [:failed, :completed]
    end
  end

  def short_commit_id
    last_commit_id[0..6]
  end

  def analyze_path
    Rails.root.join("builds", repository.github_name, "commit", last_commit_id).to_s
  end

  def analyze_file
    analyze_path + "/rbp.html"
  end

  def template_file
    Rails.root.join("app/views/builds/rbp.html.erb").to_s
  end

  def set_position
    self.position = repository.builds_count + 1
  end

  def config_directory_path
    "#{analyze_path}/#{repository.name}/config/"
  end

  def analyze
    start_time = Time.now
    FileUtils.mkdir_p(analyze_path) unless File.exist?(analyze_path)
    FileUtils.cd(analyze_path)
    g = Git.clone(repository.clone_url, repository.name)
    Dir.chdir(repository.name) { g.reset_hard(last_commit_id) }
    FileUtils.cp(repository.config_file_path, config_directory_path)
    rails_best_practices = RailsBestPractices::Analyzer.new("#{analyze_path}/#{repository.name}",
                                                            "format"         => "html",
                                                            "silent"         => true,
                                                            "output-file"    => analyze_file,
                                                            "with-github"    => true,
                                                            "github-name"    => repository.github_name,
                                                            "last-commit-id" => last_commit_id,
                                                            "with-git"       => true,
                                                            "template"       => template_file
                                                           )
    rails_best_practices.errors_filter_block = lambda do |errors|
      errors.delete_if { |error| error.git_commit.blank? }
      errors.each do |error|
        unless last_errors["#{error.short_filename} #{error.message}"] == error.git_commit
          error.highlight = true
        end
      end
     end
    rails_best_practices.analyze
    rails_best_practices.output
    end_time = Time.now
    self.warning_count = rails_best_practices.runner.errors.size
    self.duration = end_time - start_time
    self.finished_at = end_time
    complete!
    self.repository.touch(:last_build_at)
    UserMailer.notify_build_success(self).deliver
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
    fail!
  ensure
    FileUtils.rm_rf("#{analyze_path}/#{repository.name}")
  end
  handle_asynchronously :analyze

  def proxy_analyze
    start_time = Time.now
    FileUtils.mkdir_p(analyze_path) unless File.exist?(analyze_path)
    errors = []
    warnings.each do |warning|
      warning['highlight'] = (last_errors[warning['short_filename'] + warning['message']] != warning['git_commit'])
      errors << RailsBestPractices::Core::Error.new(
        :filename => warning['short_filename'],
        :line_number => warning['line_number'],
        :message => warning['message'],
        :type => warning['type'],
        :url => warning['url'],
        :git_commit => warning['git_commit'],
        :git_username => warning['git_username'],
        :highlight => warning['highlight']
      )
    end
    File.open(analyze_file, 'w+') do |file|
      eruby = Erubis::Eruby.new(File.read(template_file))
      file.puts eruby.evaluate(
        :errors         => errors,
        :github         => true,
        :github_name    => repository.github_name,
        :last_commit_id => last_commit_id,
        :git            => true
      )
    end
    end_time = Time.now
    self.warning_count = warnings.size
    self.duration = end_time - start_time
    self.finished_at = end_time
    complete!
    UserMailer.notify_build_success(self).deliver
  end

  def last_errors
    @last_errors ||= begin
      last_errors = {}
      last_build = repository.builds.where("id < ?", self.id).completed.last
      if last_build
        last_doc = Nokogiri::HTML(open(last_build.analyze_file))
        last_doc.css("table tbody tr").each do |tr|
          filename, _, message, git_commit, _ = tr.css("td").map { |td| td.text.strip }
          last_errors["#{filename} #{message}"] = git_commit
        end
      end
      last_errors
    end
  end

  protected
    def remove_analyze_file
      FileUtils.rm(analyze_file) if File.exist?(analyze_file)
    end
end
