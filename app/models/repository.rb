require 'delayed_job/sync_repository'

class Repository < ActiveRecord::Base
  has_many :builds

  attr_accessor :user

  validates :github_name, presence: true
  validates :github_id, uniqueness: true

  after_create :sync_github

  def clone_url
    private? ? ssh_url : git_url
  end

  def generate_build(commit)
    builds.create(last_commit_id: commit["id"], last_commit_message: commit["message"])
  end

  def sync_github
    Delayed::Job.enqueue(DelayedJob::SyncRepository.new(self.id, User.current.id))
  end
end
