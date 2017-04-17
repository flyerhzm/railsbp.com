require 'rails_helper'

RSpec.describe Configuration, type: :model do
  it { is_expected.to have_many(:parameters) }
  it { is_expected.to belong_to(:category) }

  context "#notify_collaborators" do
    it "should notify all collaborators" do
      expect {
        create(:configuration)
      }.to have_enqueued_job(NotifyCollaboratorsJob)
    end
  end
end
