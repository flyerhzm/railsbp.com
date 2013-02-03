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

  def html_output_file
    analyze_path + "/rbp.html"
  end

  def yaml_output_file
    analyze_path + "/rbp.yml"
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
    system("mkdir", "-p", analyze_path)
    Dir.chdir(analyze_path)
    system("git", "clone", repository.clone_url)
    system("rm", "#{repository.name}/.rvmrc")
    Dir.chdir(repository.name)
    system("git", "reset", "--hard", last_commit_id)
    system("cp", repository.config_file_path, config_directory_path)
    system("rails_best_practices --format yaml --silent --output-file #{yaml_output_file} --with-git #{analyze_path}/#{repository.name}")
    RailsBestPractices::Core::Runner.base_path = File.join(analyze_path, repository.name)
    current_errors.each do |error|
      error.highlight = (last_errors_memo[error.short_filename + error.message] != error.git_commit)
    end
    File.open(html_output_file, 'w+') do |file|
      eruby = Erubis::Eruby.new(File.read(template_file))
      file.puts eruby.evaluate(
        :errors         => current_errors,
        :github         => true,
        :github_name    => repository.github_name,
        :last_commit_id => last_commit_id,
        :git            => true
      )
    end
    end_time = Time.now
    self.warning_count = current_errors.size
    self.duration = end_time - start_time
    self.finished_at = end_time
    self.complete!
    self.repository.touch(:last_build_at)
    UserMailer.notify_build_success(self).deliver
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
    self.fail!
  ensure
    system("rm", "-rf", "#{analyze_path}/#{repository.name}")
  end
  handle_asynchronously :analyze

  def current_errors
    @current_errors ||= self.load_errors
  end

  def last_errors
    @last_errors ||= begin
                       last_build = repository.builds.where("id < ?", self.id).completed.last
                       last_build ? last_build.load_errors : []
                     end
  end

  def last_errors_memo
    @last_errors_memo ||= last_errors.inject({}) do |memo, error|
      memo[error.short_filename + error.message] = error.git_commit; memo
    end
  end

  def load_errors
    if File.exists? self.yaml_output_file
      YAML.load_file(self.yaml_output_file)
    else
      []
    end
  end

  protected
    def remove_analyze_file
      FileUtils.rm(analyze_file) if File.exist?(analyze_file)
    end
end
