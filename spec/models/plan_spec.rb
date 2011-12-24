require 'spec_helper'

describe Plan do
  it { should have_many(:users) }

  context ".free" do
    before do
      @free_plan = Factory(:plan, amount: 0)
      @paid_plan = Factory(:plan, amount: 1000)
    end
    subject { Plan.free }
    it { should == [@free_plan] }
  end
end
