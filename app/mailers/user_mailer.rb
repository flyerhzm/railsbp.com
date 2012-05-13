class UserMailer < ActionMailer::Base
  mailer_account "notification"

  default from: "notification@railsbp.com"

  def notify_build_success(build)
    @build = build
    @repository = @build.repository

    mail(to: @repository.recipient_emails,
         subject: "[Railsbp] #{@repository.github_name} build ##{@build.position}, warnings count #{@build.warning_count}")
  end

  def notify_configuration_created(configuration, repository)
    @configuration = configuration
    @repository = repository

    mail(to: @repository.recipient_emails,
         subject: "[Railsbp] new checker #{@configuration.name} added")
  end

  def notify_repository_privacy(repository)
    @repository = repository

    mail(to: @repository.recipient_emails,
         subject: "[Railsbp] private repository #{@repository.github_name} on railsbp.com")
  end
end
