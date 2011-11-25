require 'spec_helper'

describe UserRepository do
  it { should belong_to(:user) }
  it { should belong_to(:repository) }
end
