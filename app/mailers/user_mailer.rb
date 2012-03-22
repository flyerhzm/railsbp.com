class UserMailer < ActionMailer::Base
  mailer_account "notification"

  default from: "notification@railsbp.com"

  def notify_build_success(build_id)
    @build = Build.find(build_id)
    @repository = @build.repository

    mail(:to => @build.recipient_emails,
         :subject => "[Railsbp] #{@repository.github_name} build ##{@build.position}, warnings count #{@build.warning_count}")
  end
end
