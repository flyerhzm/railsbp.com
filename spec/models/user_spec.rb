require 'spec_helper'

describe User do
  it { should have_many(:user_repositories) }
  it { should have_many(:repositories).through(:user_repositories) }
end
