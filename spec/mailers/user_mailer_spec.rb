require "spec_helper"

describe UserMailer do
  context "#notify_build_success" do
    before do
      Repository.any_instance.stubs(:set_privacy)
      Repository.any_instance.stubs(:sync_github)
      @user1 = Factory(:user, email: "user1@gmail.com")
      @user2 = Factory(:user, email: "user2@gmail.com")
      @repository = Factory(:repository, github_name: "flyerhzm/test")
      @repository.users << @user1
      @repository.users << @user2
      @build = Factory(:build, repository: @repository, warning_count: 10)
    end

    subject { UserMailer.notify_build_success(@build) }
    it { should deliver_to("user1@gmail.com, user2@gmail.com") }
    it { should have_subject("[Railsbp] flyerhzm/test build #1, warnings count 10") }
    it { should have_body_text("flyerhzm/test build successfully.") }
    it { should have_body_text("<a href=\"http://localhost:3000/repositories/#{@repository.to_param}/builds/#{@build.id}\">View result here</a>") }
  end
end
