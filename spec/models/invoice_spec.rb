require 'spec_helper'

describe Invoice do
  it { should belong_to(:user) }

  context "#deliver_email" do
    it "should before create" do
      job = mock
      UserMailer.expects(:delay).returns(job)
      job.expects(:notify_payment_success)
      Factory(:invoice)
    end
  end
end
