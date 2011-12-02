require 'spec_helper'

describe Build do
  include DelayedJobSpecHelper

  it { should belong_to(:repository) }

  context "after_save" do
    it "should call analyze" do
      Build.any_instance.expects(:analyze)
      Build.create
    end
  end

  context "#analyze" do
    before do
      user = Factory(:user, :email => "flyerhzm@gmail.com")
      repository = Factory(:repository, :name => "rails_best_practices", :user => user, :git_url => "git://github.com/flyerhzm/rails_best_practices.git")
      @build = repository.builds.create(:last_commit_id => "987654321")
    end

    it "should fetch remote git and analyze" do
      path = Rails.root.join("builds/flyerhzm@gmail.com/rails_best_practices/commit/987654321").to_s
      FileUtils.expects(:mkdir).with(path)
      Git.expects(:clone).with("git://github.com/flyerhzm/rails_best_practices.git", :name => "rails_best_practices", :path => path)
      rails_best_practices = mock
      RailsBestPractices::Analyzer.expects(:new).with(path).returns(rails_best_practices)
      rails_best_practices.expects(:analyze)
      rails_best_practices.expects(:output)
      work_off
    end
  end
end
