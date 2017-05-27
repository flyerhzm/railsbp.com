require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
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
    it { is_expected.to deliver_to("user1@gmail.com, user2@gmail.com") }
    it { is_expected.to have_subject("[Railsbp] flyerhzm/test build #1, warnings count 10") }
    it { is_expected.to have_body_text("flyerhzm/test") }
    it { is_expected.to have_body_text("Build #1") }
    it { is_expected.to have_body_text("<a href=\"http://test.railsbp.com/repositories/#{@repository.to_param}/builds/#{@build.id}\">http://test.railsbp.com/repositories/#{@repository.to_param}/builds/#{@build.id}</a>") }
    it { is_expected.to have_body_text("<td>10</td>") }
    it { is_expected.to have_body_text("1234567 (develop)") }
    it { is_expected.to have_body_text("hello") }
    it { is_expected.to have_body_text("20 secs") }
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
    it { is_expected.to deliver_to("user1@gmail.com, user2@gmail.com") }
    it { is_expected.to have_subject("[Railsbp] new checker Fat Model added") }
    it { is_expected.to have_body_text("A new checker Fat Model is added on railsbp.com") }
    it { is_expected.to have_body_text("<a href=\"http://rails-bestpracitces.com\">http://rails-bestpracitces.com</a>") }
    it { is_expected.to have_body_text("<a href=\"http://test.railsbp.com/repositories/#{@repository.to_param}/configs/edit\">enable it for your repository flyerhzm/test</a>") }
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
    it { is_expected.to deliver_to("user1@gmail.com, user2@gmail.com") }
    it { is_expected.to have_subject("[Railsbp] private repository flyerhzm/test on railsbp.com") }
    it { is_expected.to have_body_text("We are appreciated that you are using railsbp.com") }
    it { is_expected.to have_body_text("your repository flyerhzm/test is a private repository on github") }
    it { is_expected.to have_body_text("<a href=\"mailto:contact-us@railsbp.com\">contact us</a>") }
  end
end
