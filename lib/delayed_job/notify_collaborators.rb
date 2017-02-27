module DelayedJob
  class NotifyCollaborators
    def initialize(configuration_id)
      @configuration_id = configuration_id
    end

    def perform
      configuration = Configuration.find(@configuration_id)
      Repository.all.each do |repository|
        UserMailer.notify_configuration_created(configuration, repository) if repository.recipient_emails.present?
      end
    end
  end
end
