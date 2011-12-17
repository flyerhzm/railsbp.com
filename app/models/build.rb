class Build < ActiveRecord::Base
  include AASM

  belongs_to :repository, :counter_cache => true

  before_create :set_position
  after_create :analyze

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

  def analyze
    run!
    start_time = Time.now
    FileUtils.mkdir_p(analyze_path) unless File.exist?(analyze_path)
    FileUtils.cd(analyze_path)
    Git.clone(repository.clone_url, repository.name)
    rails_best_practices = RailsBestPractices::Analyzer.new("#{analyze_path}/#{repository.name}",
                                                            "format"         => "html",
                                                            "silent"         => true,
                                                            "output-file"    => analyze_file,
                                                            "with-github"    => true,
                                                            "github-name"    => repository.github_name,
                                                            "last-commit-id" => last_commit_id,
                                                            "template"       => template_file
                                                           )
    rails_best_practices.analyze
    rails_best_practices.output
    FileUtils.rm_rf("#{analyze_path}/#{repository.name}")
    end_time = Time.now
    self.warning_count = rails_best_practices.runner.errors.size
    self.duration = end_time - start_time
    complete!
  end
  handle_asynchronously :analyze
end
