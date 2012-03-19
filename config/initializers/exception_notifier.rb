class ExceptionNotifier
  class Notifier < ActionMailer::Base
    if Rails.env.production?
      class <<self
        def smtp_settings
          options = YAML.load_file("#{Rails.root}/config/mailers.yml")[Rails.env]['exception_notifier']
          @@smtp_settings = {
           :address              => options["address"],
           :port                 => options["port"],
           :domain               => options["domain"],
           :authentication       => options["authentication"],
           :user_name            => options["user_name"],
           :password             => options["password"]
          }
        end
      end
    end
  end
end
