class DelayedJob::SyncRepository
  def initialize(repository_id, github_token)
    @repository_id = repository_id
    @github_token = github_token
  end

  def perform
    repository = Repository.find(@repository_id)

    client = Octokit::Client.new(oauth_token: @github_token)
    repo = client.repository(repository.github_name)
    repository.update_attributes(
      html_url: repo.html_url,
      git_url: repo.git_url,
      ssh_url: repo.ssh_url,
      name: repo.name,
      description: repo.description,
      private: repo.private,
      fork: repo.fork,
      pushed_at: repo.pushed_at,
      github_id: repo.id,
      visible: !repo.private
    )
  rescue => e
    ExceptionNotifier::Notifier.background_exception_notification(e)
  end
end
