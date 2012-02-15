class UserMailer < ActionMailer::Base
  if Rails.env.production?
    options = YAML.load_file("#{Rails.root}/config/mailers.yml")['production']['notification']
    self.smtp_settings = {
      :address        => options["address"],
      :port           => options["port"],
      :domain         => options["domain"],
      :authentication => options["authentication"],
      :user_name      => options["user_name"],
      :password       => options["password"]
    }
  end

  default from: "notification@railsbp.com"

  def notify_build_success(build_id)
    @build = Build.find(build_id)
    @repository = @build.repository

    mail(:to => @build.recipient_emails,
         :subject => "[Railsbp] #{@repository.github_name} build ##{@build.position}, warnings count #{@build.warning_count}")
  end
end
