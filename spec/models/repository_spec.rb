require 'spec_helper'

describe Repository do
  it { should have_many(:builds) }

  context "#generate_build" do
    before do
      user = Factory(:user)
      User.current = user
    end

    subject { Factory(:repository) }
    it "should create a build" do
      lambda { subject.generate_build("987654321") }.should change(subject.builds, :count).by(1)
    end
  end

  context "#clone_url" do
    context "private" do
      subject { Factory(:repository, :private => false, :git_url => "git://github.com/flyerhzm/rails-bestpractices.com.git") }
      its(:clone_url) { should == "git://github.com/flyerhzm/rails-bestpractices.com.git" }
    end

    context "public" do
      subject { Factory(:repository, :private => true, :ssh_url => "git@github.com:flyerhzm/railsbp.com.git") }
      its(:clone_url) { should == "git@github.com:flyerhzm/railsbp.com.git" }
    end
  end

  context "#sync_github" do
    before do
      repo = File.read(Rails.root.join("spec/fixtures/repository.json"))
      stub_request(:get, "https://api.github.com/repos/flyrhzm/railsbp.com").to_return(:body => repo)
      user = Factory(:user)
      User.current = user
    end

    subject do
      repository = Factory(:repository, :github_name => "flyerhzm/rack")
      Delayed::Worker.new.work_off
      repository.reload
    end

    its(:html_url) { should == "https://github.com/flyerhzm/railsbp.com" }
    its(:git_url) { should == "git://github.com/flyerhzm/railsbp.com.git" }
    its(:ssh_url) { should == "git@github.com:flyerhzm/railsbp.com.git" }
    its(:name) { should == "railsbp.com" }
    its(:description) { should == "railsbp.com" }
    its(:private) { should be_true }
    its(:fork) { should be_false }
    its(:github_id) { should == 2860164 }
  end
end
