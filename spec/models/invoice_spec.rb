require 'spec_helper'

describe Invoice do
  it { should belong_to(:user) }
end
