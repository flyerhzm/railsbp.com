class DelayedJob::SyncRepository
  def initialize(repository_id, user_id)
    @repository_id = repository_id
    @user_id = user_id
  end

  def perform
    repository = Repository.find(@repository_id)
    user = User.find(@user_id)

    client = Octokit::Client.new(oauth_token: user.github_token)
    repo = client.repository(repository.github_name)
    repository.update_attributes(
      html_url: repo.html_url,
      git_url: repo.git_url,
      ssh_url: repo.ssh_url,
      name: repo.name,
      description: repo.description,
      private: repo.private,
      fork: repo.fork,
      master_branch: repo.master_branch,
      pushed_at: repo.pushed_at,
      github_id: repo.id
    )
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
  end
end
