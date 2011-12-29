require 'spec_helper'

describe User do
  it { should have_many(:user_repositories) }
  it { should have_many(:repositories).through(:user_repositories) }
  it { should have_many(:invoices) }
  it { should have_one(:credit_card) }
  it { should belong_to(:plan) }

  context "#create" do
    before do
      @free_plan = Factory(:plan, amount: 0)
      @paid_plan = Factory(:plan, amount: 1000)
    end
    subject { Factory(:user) }
    its(:plan) { should == @free_plan }
  end

  context "aasm_state" do
    subject { Factory(:user) }
    its(:aasm_state) { should == "unpaid" }

    context "#pay!" do
      before do
        invoice = Factory(:invoice, :user => subject)
        subject.expects(:notify_user_pay)
        subject.pay!
      end
      its(:aasm_state) { should == "paid" }

      it "should allow pay! more than once" do
        subject.stubs(:notify_user_pay)
        subject.pay!
        lambda { subject.pay! }.should_not raise_error
      end
    end

    context "#unpay!" do
      before do
        subject.stubs(:notify_user_pay)
        subject.pay!
        subject.expects(:notify_user_unpay)
        subject.unpay!
      end
      its(:aasm_state) { should == "unpaid" }
    end

    context "#trial!" do
      before do
        subject.trial!
      end
      its(:aasm_state) { should == "trial" }
    end
  end

  context "#update_plan" do
    subject { Factory(:user, stripe_customer_token: "123456") }
    let(:free_plan) { Factory(:plan, amount: 0, trial_period_days: 0, name: "Free", identifier: "free") }
    let(:basic_plan) { Factory(:plan, amount: 500, trial_period_days: 7, name: "Basic", identifier: "basic") }

    context "free to basic" do
      before do
        subject.update_attribute(:plan, free_plan)
        customer = mock
        Stripe::Customer.expects(:retrieve).with("123456").returns(customer)
        customer.expects(:update_subscription).with(plan: "basic")
        subject.update_plan(basic_plan)
      end
      its(:aasm_state) { should == "trial" }
      its(:plan) { should == basic_plan }
    end

    context "basic to free" do
      before do
        subject.update_attribute(:plan, basic_plan)
        subject.trial!
        customer = mock
        Stripe::Customer.expects(:retrieve).with("123456").returns(customer)
        customer.expects(:update_subscription).with(plan: "free")
        subject.update_plan(free_plan)
      end
      its(:aasm_state) { should == "unpaid" }
      its(:plan) { should == free_plan }
    end
  end

  context "#fakemail?" do
    context "flyerhzm" do
      subject { Factory(:user, email: "flyerhzm@gmail.com") }
      its(:fakemail?) { should be_false }
    end
    context "flyerhzm-test" do
      subject { Factory(:user, email: "flyerhzm-test@fakemail.com") }
      its(:fakemail?) { should be_true }
    end
  end
end
