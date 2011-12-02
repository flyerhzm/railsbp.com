require 'spec_helper'

describe User do
  it { should have_many(:user_repositories) }
  it { should have_many(:repositories).through(:user_repositories) }

  context "#sync_repositories" do
    before do
      repos = File.read(Rails.root.join("spec/fixtures/repositories.json"))
      stub_request(:get, "https://api.github.com/user/repos").to_return(:body => repos)
    end

    subject { Factory(:user).tap { |user| user.sync_repositories } }
    it { should have(30).repositories }
  end
end
