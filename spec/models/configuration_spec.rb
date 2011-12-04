require 'spec_helper'

describe Configuration do
  it { should have_many(:parameters) }
  it { should belong_to(:category) }
end
