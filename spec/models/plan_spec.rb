require 'spec_helper'

describe Plan do
  it { should have_many(:subscriptions) }
end
