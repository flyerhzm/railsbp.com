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

  scope :completed, -> { where(:aasm_state => "completed") }

  aasm do
    state :scheduled, initial: true
    state :running, enter: :analyze
    state :completed
    state :failed

    event :run do
      transitions to: :running, from: :scheduled
    end

    event :complete do
      transitions to: :completed, from: [:running, :scheduled, :completed]
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

  def analyze
    AnalyzeBuildJob.perform_later(id)
  end

  def analyze_path
    Rails.root.join("builds", repository.github_name, "commit", last_commit_id).to_s
  end

  def config_directory_path
    "#{analyze_path}/#{repository.name}/config/"
  end

  def yaml_output_file
    analyze_path + "/rbp.yml"
  end

  def current_errors
    @current_errors ||= load_errors
  end

  def last_errors_memo
    @last_errors_memo ||= last_errors.inject({}) do |memo, error|
      memo[error.short_filename + error.message] = error.git_commit; memo
    end
  end

  def html_output_file
    analyze_path + "/rbp.html"
  end

  def template_file
    Rails.root.join("app/views/builds/rbp.html.erb").to_s
  end

  def load_errors
    if File.exist? yaml_output_file
      YAML.load_file(yaml_output_file)
    else
      []
    end
  end

  private

  def set_position
    self.position = repository.builds_count + 1
  end

  def remove_analyze_file
    FileUtils.rm(analyze_file) if File.exist?(analyze_file)
  end

  def last_errors
    @last_errors ||= begin
                       last_build = repository.builds.where("id < ?", id).completed.last
                       last_build ? last_build.load_errors : []
                     end
  end
end
