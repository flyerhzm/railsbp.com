require 'rails_helper'

RSpec.describe NotifyCollaboratorsJob do
  let(:configuration) { create :configuration }
  let(:repository1) { create :repository }
  let(:repository2) { create :repository }
  let(:user1) { create :user }
  let(:user2) { create :user }

  before do
    repository1.users << user1
    repository2.users << user2
  end

  it 'notifies to all recipients for all repositories' do
    expect(UserMailer).to receive(:notify_configuration_created).with(configuration, repository1).and_return(double('UserMailer', deliver: true))
    expect(UserMailer).to receive(:notify_configuration_created).with(configuration, repository2).and_return(double('UserMailer', deliver: true))
    NotifyCollaboratorsJob.new.perform(configuration.id)
  end
end
