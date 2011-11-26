require 'spec_helper'

describe User do
  include DelayedJobSpecHelper

  it { should have_many(:user_repositories) }
  it { should have_many(:repositories).through(:user_repositories) }

  context "#sync_repositories" do
    before :each do
      repos = File.read(Rails.root.join("spec/fixtures/repositories.json"))
      stub_request(:get, "https://api.github.com/user/repos").to_return(:body => repos)

      @user = Factory(:user)
      work_off
    end

    it "should sync user repositories" do
      @user.should have(30).repositories
    end
  end
end
