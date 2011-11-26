class User < ActiveRecord::Base
  include Gravtastic
  is_gravtastic

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :user_repositories
  has_many :repositories, :through => :user_repositories

  after_create :sync_repositories

  def self.find_for_github_oauth(data)
    if user = User.find_by_github_uid(data.uid)
      user
    else # Create a user with a stub password.
      user = User.new(:email => data.info.email, :password => Devise.friendly_token[0, 20])
      user.github_uid = data.uid
      user.github_token = data.credentials.token
      user.name = data.info.name
      user.nickname = data.info.nickname
      user.save
      user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.github_data"] && session["devise.github_data"]["user_info"]
        user.email = data["email"]
      end
    end
  end

  def sync_repositories
    client = Octokit::Client.new(oauth_token: github_token)
    client.repositories.each do |repo|
      repositories << Repository.create(
        :url => repo.url,
        :git_url => repo.git_url,
        :name => repo.name,
        :description => repo.description,
        :private => repo.private,
        :fork => repo.fork,
        :master_branch => repo.master_branch,
        :pushed_at => repo.pushed_at,
        :github_id => repo.id
      )
    end
    self.update_attribute(:sync_repos, true)
  end
  handle_asynchronously :sync_repositories
end
