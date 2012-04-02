class UserMailer < ActionMailer::Base
  mailer_account "notification"

  default from: "notification@railsbp.com"

  def notify_build_success(build)
    @build = build
    @repository = @build.repository

    mail(to: @repository.recipient_emails,
         subject: "[Railsbp] #{@repository.github_name} build ##{@build.position}, warnings count #{@build.warning_count}")
  end
end
