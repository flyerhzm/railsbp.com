class DelayedJob::SyncCollaborators
  def initialize(repository_id, github_token)
    @repository_id = repository_id
    @github_token = github_token
  end

  def perform
    repository = Repository.find(@repository_id)
    existing_user_ids = repository.user_repositories.map(&:user_id)

    client = Octokit::Client.new(oauth_token: @github_token)
    client.collaborators(repository.github_name).each do |collaborator|
      unless user = User.where(github_uid: collaborator.id).first
        user = User.new(email: "#{collaborator.login}@fakemail.com", password: Devise.friendly_token[0, 20])
        user.github_uid = collaborator.id
        user.save
      end
      repository.users << user unless existing_user_ids.include?(user.id)
    end
  end
end
