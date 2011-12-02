require 'spec_helper'

describe Repository do
  it { should have_many(:builds) }
  it { should belong_to(:user) }

  context "#generate_build" do
    subject { Factory(:repository) }
    it "should create a build" do
      lambda { subject.generate_build }.should change(subject.builds, :count).by(1)
    end
  end

  context "#unique_name" do
    subject { Factory(:repository, :name => "rails_best_practices", :user => Factory(:user, :email => "flyerhzm@gmail.com")) }
    its(:unique_name) { should == "flyerhzm@gmail.com/rails_best_practices" }
  end
end
