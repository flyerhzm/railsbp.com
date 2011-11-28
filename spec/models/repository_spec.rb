require 'spec_helper'

describe Repository do
  it { should have_many(:builds) }

  context "generate_build" do
    subject { Factory(:repository) }
    it "should create a build" do
      lambda { subject.generate_build }.should change(subject.builds, :count).by(1)
    end
  end
end
