require 'rails_helper'

RSpec.describe Configuration, type: :model do
  it { is_expected.to have_many(:parameters) }
  it { is_expected.to belong_to(:category) }

  context "#notify_collaborators" do
    before do
      skip_repository_callbacks
      @repository1 = create(:repository)
      @repository2 = create(:repository)
    end

    it "should notify all collaborators" do
      @configuration = create(:configuration)
      allow_any_instance_of(Repository).to receive(:recipient_emails).and_return(['team@railsbp.com'])
      expect(UserMailer).to receive(:notify_configuration_created).with(@configuration, @repository1)
      expect(UserMailer).to receive(:notify_configuration_created).with(@configuration, @repository2)
      Delayed::Worker.new.work_off
    end
  end
end
