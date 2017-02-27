# == Schema Information
#
# Table name: repositories
#
#  id                   :integer(4)      not null, primary key
#  git_url              :string(255)
#  name                 :string(255)
#  description          :string(255)
#  private              :boolean(1)
#  fork                 :boolean(1)
#  pushed_at            :datetime
#  created_at           :datetime
#  updated_at           :datetime
#  github_id            :integer(4)
#  html_url             :string(255)
#  ssh_url              :string(255)
#  github_name          :string(255)
#  builds_count         :integer(4)      default(0)
#  authentication_token :string(255)
#  visible              :boolean(1)      default(FALSE), not null
#  collaborators_count  :integer(4)      default(0), not null
#  last_build_at        :datetime
#

require 'authorization_exception'

class Repository < ActiveRecord::Base
  has_many :user_repositories, dependent: :destroy
  has_many :users, -> { distinct }, through: :user_repositories
  has_many :owners, -> { where("user_repositories.own": true) }, through: :user_repositories, source: :user
  has_many :builds, dependent: :destroy

  validates :github_name, presence: true, uniqueness: true
  validates :github_id, uniqueness: true

  before_create :reset_authentication_token, :sync_github, :touch_last_build_at
  after_create :copy_config_file, :setup_github_hook

  scope :visible, -> { where(visible: true) }

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

  def generate_build(branch, commit)
    return unless commit

    build = self.builds.build(branch: branch, last_commit_id: commit["id"], last_commit_message: commit["message"])
    if build.save
      build.run!
    end
  end

  def sync_collaborators
    Delayed::Job.enqueue(DelayedJob::SyncCollaborators.new(self.id, User.current.id))
  end

  def delete_collaborator(user_id)
    user = User.find(user_id)
    self.users.destroy(user)
  end

  def add_collaborator(login)
    client = Octokit::Client.new(oauth_token: User.current.github_token)
    github_user = client.user(login)

    unless user = User.where(github_uid: github_user.id).first
      user = User.new(email: "#{github_user.login}@fakemail.com", password: Devise.friendly_token[0, 20])
      user.github_uid = github_user.id
      user.name = github_user.name
      user.nickname = github_user.login
      user.save
    end
    add_collaborator_if_necessary(user)
  end

  def add_collaborator_if_necessary(user)
    unless collaborator_ids.include?(user.id)
      self.user_repositories.create(user: user, own: false)
    end
  end

  def collaborator_ids
    user_repositories.map(&:user_id)
  end

  def recipient_emails
    users.select { |user| user.email !~ /fakemail.com$/ }.map(&:email)
  end

  def notify_privacy
    if recipient_emails.present?
      UserMailer.notify_repository_privacy(self).deliver
    end
  end

  def configs
    @configs ||= RepositoryConfigs.new(@repository).read
  end

  def to_param
    "#{id}-#{github_name.parameterize}"
  end

  protected
    def reset_authentication_token
      self.authentication_token = Devise.friendly_token
    end

    def sync_github
      client = Octokit::Client.new(oauth_token: User.current.github_token)
      repo = client.repository(github_name)
      self.html_url = repo.html_url
      self.git_url = repo.git_url
      self.ssh_url = repo.ssh_url
      self.name = repo.name
      self.description = repo.description
      self.private = repo.private
      self.fork = repo.fork
      self.pushed_at = repo.pushed_at
      self.github_id = repo.id
      self.visible = !repo.private
      true
    end

    def copy_config_file
      FileUtils.mkdir_p(config_path) unless File.exist?(config_path)
      FileUtils.cp(default_config_file_path, config_file_path)
    end

    def touch_last_build_at
      self.last_build_at = Time.now
    end

    def setup_github_hook
      client = Octokit::Client.new(oauth_token: User.current.github_token)
      client.create_hook(self.github_name, "railsbp", {:railsbp_url => "http://railsbp.com", :token => self.authentication_token})
      true
    end
end
