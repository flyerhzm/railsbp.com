require 'spec_helper'

describe Parameter do
  it { should belong_to(:configuration) }
end
