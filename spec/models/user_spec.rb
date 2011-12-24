require 'spec_helper'

describe User do
  it { should have_many(:user_repositories) }
  it { should have_many(:repositories).through(:user_repositories) }
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
end
