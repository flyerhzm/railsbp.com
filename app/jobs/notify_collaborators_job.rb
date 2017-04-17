class NotifyCollaboratorsJob < ActiveJob::Base
  queue_as :default

  def perform(configuration_id)
    configuration = Configuration.find(configuration_id)
    Repository.all.each do |repository|
      UserMailer.notify_configuration_created(configuration, repository).deliver if repository.recipient_emails.present?
    end
  end
end
