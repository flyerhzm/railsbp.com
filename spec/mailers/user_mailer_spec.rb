require "spec_helper"

describe UserMailer do
  before { skip_repository_callbacks }

  context "#notify_build_success" do
    before do
      @user1 = create(:user, email: "user1@gmail.com")
      @user2 = create(:user, email: "user2@gmail.com")
      @repository = create(:repository, github_name: "flyerhzm/test")
      @repository.users << @user1
      @repository.users << @user2
      @build = create(:build, repository: @repository, warning_count: 10, last_commit_id: "123456789", branch: "develop", last_commit_message: "hello", duration: 20)
    end

    subject { UserMailer.notify_build_success(@build) }
    it { should deliver_to("user1@gmail.com, user2@gmail.com") }
    it { should have_subject("[Railsbp] flyerhzm/test build #1, warnings count 10") }
    it { should have_body_text("flyerhzm/test") }
    it { should have_body_text("Build #1") }
    it { should have_body_text("<a href=\"http://localhost:3000/repositories/#{@repository.to_param}/builds/#{@build.id}\">http://localhost:3000/repositories/#{@repository.to_param}/builds/#{@build.id}</a>") }
    it { should have_body_text("<td>10</td>") }
    it { should have_body_text("1234567 (develop)") }
    it { should have_body_text("hello") }
    it { should have_body_text("20 secs") }
  end

  context "#notify_configuration_created" do
    before do
      @user1 = create(:user, email: "user1@gmail.com")
      @user2 = create(:user, email: "user2@gmail.com")
      @repository = create(:repository, github_name: "flyerhzm/test")
      @repository.users << @user1
      @repository.users << @user2
      @configuration = create(:configuration, name: "Fat Model", url: "http://rails-bestpracitces.com")
    end

    subject { UserMailer.notify_configuration_created(@configuration, @repository) }
    it { should deliver_to("user1@gmail.com, user2@gmail.com") }
    it { should have_subject("[Railsbp] new checker Fat Model added") }
    it { should have_body_text("A new checker Fat Model is added on railsbp.com") }
    it { should have_body_text("<a href=\"http://rails-bestpracitces.com\">http://rails-bestpracitces.com</a>") }
    it { should have_body_text("<a href=\"http://localhost:3000/repositories/#{@repository.to_param}/configs/edit\">enable it for your repository flyerhzm/test</a>") }
  end

  context "#notify_repository_privacy" do
    before do
      @user1 = create(:user, email: "user1@gmail.com")
      @user2 = create(:user, email: "user2@gmail.com")
      @repository = create(:repository, github_name: "flyerhzm/test")
      @repository.users << @user1
      @repository.users << @user2
    end

    subject { UserMailer.notify_repository_privacy(@repository) }
    it { should deliver_to("user1@gmail.com, user2@gmail.com") }
    it { should have_subject("[Railsbp] private repository flyerhzm/test on railsbp.com") }
    it { should have_body_text("We are appreciated that you are using railsbp.com") }
    it { should have_body_text("your repository flyerhzm/test is a private repository on github") }
    it { should have_body_text("<a href=\"https://github.com/railsbp/railsbp.com\">fork railsbp.com on github</a>") }
    it { should have_body_text("<a href=\"mailto:contact-us@railsbp.com\">contact us</a>") }
  end
end
