require "spec_helper"

describe UserMailer do
  context "#notify_payment_access" do
    let(:plan) { Factory(:plan, amount: 500, name: "Basic") }
    let(:user) { Factory(:user, email: "flyerhzm@gmail.com", nickname: "flyerhzm").tap { |user| user.update_attribute(:plan, plan) } }
    let(:invoice) { Factory(:invoice, user: user, total: 500) }

    subject { UserMailer.notify_payment_success(invoice.id) }
    it { should deliver_to("flyerhzm@gmail.com") }
    it { should have_subject("[Railsbp] Payment Receipt") }
    it { should have_body_text("<a href='mailto:support@railsbp.com'>support@railsbp.com</a>") }
    it { should have_body_text("User: flyerhzm") }
    it { should have_body_text("Plan: Basic") }
    it { should have_body_text("Amount: USD $5.00") }
  end

  context "#notify_payment_final_failed" do
    let(:user) { Factory(:user, email: "flyerhzm@gmail.com", nickname: "flyerhzm") }

    subject { UserMailer.notify_payment_final_failed(user.id) }
    it { should deliver_to("flyerhzm@gmail.com") }
    it { should have_subject("[Railsbp] Payment Failed") }
    it { should have_body_text("Please update your credit card soon.") }
    it { should have_body_text("<a href='http://localhost:3000/plans'>update credit card</a>") }
  end

  context "#notify_payment_failed" do
    let(:user) { Factory(:user, email: "flyerhzm@gmail.com", nickname: "flyerhzm") }

    subject { UserMailer.notify_payment_final_failed(user.id) }
    it { should deliver_to("flyerhzm@gmail.com") }
    it { should have_subject("[Railsbp] Payment Failed") }
    it { should have_body_text("Please update your credit card soon.") }
    it { should have_body_text("<a href='http://localhost:3000/plans'>update credit card</a>") }
  end

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

    subject { UserMailer.notify_build_success(@build.id) }
    it { should deliver_to("user1@gmail.com, user2@gmail.com") }
    it { should have_subject("[Railsbp] flyerhzm/test build #1, warnings count 10") }
    it { should have_body_text("flyerhzm/test build successfully.") }
    it { should have_body_text("<a href=\"http://localhost:3000/repositories/#{@repository.to_param}/builds/#{@build.id}\">View result here</a>") }
  end
end
