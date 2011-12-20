require 'spec_helper'

describe Subscription do
  it { should belong_to(:plan) }
  it { should validate_presence_of(:plan_id) }
  it { should validate_presence_of(:email) }
end
