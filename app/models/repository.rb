require 'delayed_job/sync_repository'

class Repository < ActiveRecord::Base
  has_many :user_repositories
  has_many :users, through: :user_repositories
  has_many :builds, dependent: :destroy

  validates :github_name, presence: true
  validates :github_id, uniqueness: true

  before_create :reset_authentication_token
  after_create :copy_config_file, :sync_github

  def clone_url
    private? ? ssh_url : git_url
  end

  def default_config_file_path
    Rails.root.join("config/rails_best_practices.yml").to_s
  end

  def config_path
    Rails.root.join("builds", github_name).to_s
  end

  def config_file_path
    config_path + "/rails_best_practices.yml"
  end

  def generate_build(commit)
    builds.create(last_commit_id: commit["id"], last_commit_message: commit["message"])
  end

  def sync_collaborators
    Delayed::Job.enqueue(DelayedJob::SyncCollaborators.new(self.id, User.current.github_token))
  end

  def delete_collaborator(user_id)
    user_repositories.where(user_id: user_id).destroy
  end

  def add_collaborator(login)
    client = Octokit::Client.new(oauth_token: User.current.github_token)
    github_user = client.user(login)

    unless user = User.where(github_uid: github_user.id).first
      user = User.new(email: github_user.email, password: Devise.friendly_token[0, 20])
      user.github_uid = github_user.id
      user.name = github_user.name
      user.nickname = github_user.login
      user.save
    end
    add_collaborator_if_necessary(user)
  end

  def add_collaborator_if_necessary(user)
    unless collaborator_ids.include?(user.id)
      self.users << user
    end
  end

  def collaborator_ids
    user_repositories.map(&:user_id)
  end

  protected
    def reset_authentication_token
      self.authentication_token = Devise.friendly_token
    end

    def copy_config_file
      FileUtils.mkdir_p(config_path) unless File.exist?(config_path)
      FileUtils.cp(default_config_file_path, config_file_path)
    end

    def sync_github
      Delayed::Job.enqueue(DelayedJob::SyncRepository.new(self.id, User.current.github_token))
    end
end
