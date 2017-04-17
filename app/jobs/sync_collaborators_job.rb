class SyncCollaboratorsJob < ActiveJob::Base
  queue_as :default

  def perform(repository_id, user_id)
    repository = Repository.find(repository_id)
    user = User.find(user_id)
    User.current = user

    client = Octokit::Client.new(oauth_token: user.github_token)
    client.collaborators(repository.github_name).each do |collaborator|
      unless user = User.where(github_uid: collaborator.id).first
        user = User.new(email: "#{collaborator.login}@fakemail.com", password: Devise.friendly_token[0, 20])
        user.github_uid = collaborator.id
        user.nickname = collaborator.login
        user.save
      end
      repository.add_collaborator_if_necessary(user)
    end
  end
end
