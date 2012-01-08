require 'spec_helper'

describe Plan do
  it { should have_many(:users) }

  context ".free" do
    before do
      @free_plan = Factory(:plan, amount: 0)
      @paid_plan = Factory(:plan, amount: 1000)
    end
    subject { Plan.free.last }
    it { should == @free_plan }
  end

  context "#free?" do
    it "should be true if amount == 0" do
      Factory(:plan, amount: 0).should be_free
    end

    it "should be false if amount > 0" do
      Factory(:plan, amount: 500).should_not be_free
    end
  end

  context "#has_trial?" do
    it "should has trial if trial_period_days > 0" do
      Factory(:plan, trial_period_days: 7).should be_has_trial
    end

    it "should not has trial if trial_period_days = 0" do
      Factory(:plan, trial_period_days: 0).should_not be_has_trial
    end
  end
end
