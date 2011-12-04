class Build < ActiveRecord::Base
  include AASM

  belongs_to :repository

  after_create :analyze

  aasm do
    state :scheduled, :initial => true
    state :running
    state :completed

    event :run do
      transitions :to => :running, :from => [:scheduled, :running]
    end

    event :complete do
      transitions :to => :completed, :from => :running
    end
  end

  def analyze
    run!
    absolute_path = Rails.root.join("builds", repository.github_name, "commit", last_commit_id).to_s
    FileUtils.mkdir_p(absolute_path) unless File.exist?(absolute_path)
    FileUtils.cd(absolute_path)
    Git.clone(repository.clone_url, repository.name)
    rails_best_practices = RailsBestPractices::Analyzer.new(absolute_path, 'format' => 'html', "silent" => true, "output-file" => absolute_path + "/rbp.html")
    rails_best_practices.analyze
    rails_best_practices.output
    FileUtils.rm_rf("#{absolute_path}/#{repository.name}")
    complete!
  end
  handle_asynchronously :analyze
end
