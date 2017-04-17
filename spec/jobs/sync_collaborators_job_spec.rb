require 'rails_helper'

RSpec.describe SyncCollaboratorsJob do
  let(:repository) { create :repository, github_name: 'railsbp/railsbp.com' }
  let!(:flyerhzm) { create(:user, github_uid: 66836) }
  let!(:scott) { create(:user, github_uid: 366) }
  let!(:ben) { create(:user, github_uid: 149420) }

  before do
    repository.users << flyerhzm
    repository.users << scott
    stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com/collaborators").
      to_return(headers: { "Content-Type": "application/json" }, body: File.new(Rails.root.join("spec/fixtures/collaborators.json")))
    SyncCollaboratorsJob.new.perform(repository.id, flyerhzm.id)
  end

  subject { repository.reload }

  it "should include existed user" do
    expect(subject.users).to be_include(ben)
  end

  it "should include new created user" do
    expect(subject.users).to be_include(User.find_by(github_uid: 10122))
  end
end
