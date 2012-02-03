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
#

class Build < ActiveRecord::Base
  include AASM

  belongs_to :repository, :counter_cache => true

  before_create :set_position
  after_destroy :remove_analyze_file

  attr_accessor :warnings

  scope :completed, where(:aasm_state => "completed")

  aasm do
    state :scheduled, initial: true
    state :running
    state :completed

    event :run do
      transitions to: :running, from: [:scheduled, :running]
    end

    event :complete do
      transitions to: :completed, from: :running
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
    Rails.root.join("app/views/builds/_rbp.html.erb").to_s
  end

  def set_position
    self.position = repository.builds_count + 1
  end

  def recipient_emails
    repository.users.select { |user| user.email !~ /fakemail.com$/ }.map(&:email)
  end

  def config_directory_path
    "#{analyze_path}/config"
  end

  def analyze
    run!
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
    rails_best_practices.analyze
    rails_best_practices.output
    end_time = Time.now
    self.warning_count = rails_best_practices.runner.errors.size
    self.duration = end_time - start_time
    self.finished_at = end_time
    complete!
    UserMailer.notify_build_success(self.id).deliver
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
  ensure
    FileUtils.rm_rf("#{analyze_path}/#{repository.name}")
  end
  handle_asynchronously :analyze

  def proxy_analyze
    run!
    start_time = Time.now
    FileUtils.mkdir_p(analyze_path) unless File.exist?(analyze_path)
    errors = []
    warnings.each do |warning|
      errors << RailsBestPractices::Core::Error.new(
        :filename => warning['short_filename'],
        :line_number => warning['line_number'],
        :message => warning['message'],
        :type => warning['type'],
        :url => warning['url'],
        :git_commit => warning['git_commit'],
        :git_username => warning['git_username']
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
    UserMailer.notify_build_success(self.id).deliver
  end

  protected
    def remove_analyze_file
      FileUtils.rm(analyze_file) if File.exist?(analyze_file)
    end
end
