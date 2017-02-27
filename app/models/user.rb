# == Schema Information
#
# Table name: users
#
#  id                     :integer(4)      not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(128)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer(4)      default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  github_uid             :integer(4)
#  nickname               :string(255)
#  name                   :string(255)
#  github_token           :string(255)
#  own_repositories_count :integer(4)      default(0), not null
#  admin                  :boolean(1)      default(FALSE), not null
#

class User < ActiveRecord::Base
  include Gravtastic
  is_gravtastic

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  # Setup accessible (or protected) attributes for your model

  has_many :user_repositories
  has_many :repositories, -> { distinct }, through: :user_repositories
  has_many :own_repositories, -> { where("user_repositories.own": true) }, through: :user_repositories, source: :repository

  def self.find_for_github_oauth(data)
    user = User.find_by(github_uid: data.uid) || User.new
    import_github_data(user, data)
    user.save
    user
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def add_repository(github_name)
    if own_repository?(github_name) || org_repository?(github_name)
      self.repositories.create(github_name: github_name)
    else
      raise AuthorizationException.new("Seems you are not the owner or collaborator of this repository")
    end
  end

  def fakemail?
    email =~ /@fakemail.com/
  end

  protected
    def self.import_github_data(user, data)
      user.email = data.info.email || "#{data.info.nickname}@fakemail.com"
      user.password = Devise.friendly_token[0, 20]
      user.github_uid = data.uid
      user.github_token = data.credentials.token
      user.name = data.info.name
      user.nickname = data.info.nickname
    end

    def own_repository?(github_name)
      github_name.include?("/") && github_name.split("/").first == self.nickname
    end

    def org_repository?(github_name)
      client = Octokit::Client.new(oauth_token: github_token)
      collaborators = client.collaborators(github_name)
      collaborators && collaborators.any? { |collaborator| collaborator.id == github_uid }
    end
end
