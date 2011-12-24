require 'spec_helper'

describe Branch do
  it { should belong_to(:repository) }
end
