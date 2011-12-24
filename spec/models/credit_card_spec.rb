require 'spec_helper'

describe CreditCard do
  it { should belong_to(:user) }

  context "#expire_date" do
    subject { Factory(:credit_card, :exp_month => 1, :exp_year => 2013) }
    its(:expire_date) { should == "01/2013" }
  end
end
