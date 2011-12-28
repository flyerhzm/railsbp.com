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
  end

  context "#notify_payment_failed" do
    let(:user) { Factory(:user, email: "flyerhzm@gmail.com", nickname: "flyerhzm") }

    subject { UserMailer.notify_payment_final_failed(user.id) }
    it { should deliver_to("flyerhzm@gmail.com") }
    it { should have_subject("[Railsbp] Payment Failed") }
    it { should have_body_text("Please update your credit card soon.") }
  end
end
