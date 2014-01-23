require 'spec_helper'

describe Configuration do
  it { should have_many(:parameters) }
  it { should belong_to(:category) }

  context "#notify_collaborators" do
    before do
      skip_repository_callbacks
      @repository1 = create(:repository)
      @repository2 = create(:repository)
    end

    it "should notify all collaborators" do
      @configuration = create(:configuration)
      UserMailer.expects(:notify_configuration_created).with(@configuration, @repository1)
      UserMailer.expects(:notify_configuration_created).with(@configuration, @repository2)
      Delayed::Worker.new.work_off
    end
  end
end
