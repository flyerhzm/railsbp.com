require "spec_helper"

describe UserMailer do
  before do
    Repository.any_instance.stubs(:set_privacy)
    Repository.any_instance.stubs(:sync_github)
  end

  context "#notify_build_success" do
    before do
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

  context "#notify_configuration_created" do
    before do
      @user1 = Factory(:user, email: "user1@gmail.com")
      @user2 = Factory(:user, email: "user2@gmail.com")
      @repository = Factory(:repository, github_name: "flyerhzm/test")
      @repository.users << @user1
      @repository.users << @user2
      @configuration = Factory(:configuration, name: "Fat Model", url: "http://rails-bestpracitces.com")
    end

    subject { UserMailer.notify_configuration_created(@configuration, @repository) }
    it { should deliver_to("user1@gmail.com, user2@gmail.com") }
    it { should have_subject("[Railsbp] new checker Fat Model added") }
    it { should have_body_text("A new checker Fat Model is added on railsbp.com") }
    it { should have_body_text("<a href=\"http://rails-bestpracitces.com\">http://rails-bestpracitces.com</a>") }
    it { should have_body_text("<a href=\"http://localhost:3000/repositories/#{@repository.to_param}/configs/edit\">enable it for your repository flyerhzm/test</a>") }
  end
end
