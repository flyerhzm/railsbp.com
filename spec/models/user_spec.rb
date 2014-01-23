require 'spec_helper'

describe User do
  it { should have_many(:user_repositories) }
  it { should have_many(:repositories).through(:user_repositories) }

  context "#add_repository" do
    before do
      skip_repository_callbacks
      @user = create(:user, nickname: "flyerhzm", github_uid: 66836)
      @repository = create(:repository, github_name: "flyerhzm/old")
      @user.repositories << @repository
    end

    it "should create a new repository within his own account" do
      lambda { @user.add_repository("flyerhzm/new") }.should change(@user.repositories, :count).by(1)
    end

    it "should create a new repository when he is a collaborator" do
      collaborators = File.read(Rails.root.join("spec/fixtures/collaborators.json").to_s)
      stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com/collaborators").to_return(body: MultiJson.decode(collaborators))
      lambda { @user.add_repository("railsbp/railsbp.com") }.should change(@user.repositories, :count).by(1)
    end

    it "should not create a new repository when he don't have privilege" do
      stub_request(:get, "https://api.github.com/repos/test/test.com/collaborators").to_return(body: MultiJson.decode("[]"))
      lambda { @user.add_repository("test/test.com") }.should raise_exception(AuthorizationException)
    end

    it "should attach to an old repository" do
      lambda { @user.add_repository("flyerhzm/old") }.should_not change(@user.repositories, :count)
    end
  end

  context "#fakemail?" do
    context "flyerhzm" do
      subject { create(:user, email: "flyerhzm@gmail.com") }
      its(:fakemail?) { should be_false }
    end
    context "flyerhzm-test" do
      subject { create(:user, email: "flyerhzm-test@fakemail.com") }
      its(:fakemail?) { should be_true }
    end
  end
end
