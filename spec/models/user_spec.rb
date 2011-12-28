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
  end
end
