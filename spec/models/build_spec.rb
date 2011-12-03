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
      repository = Factory(:repository, :name => "railsbp.com", :user => user, :git_url => "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(:last_commit_id => "987654321")
    end

    it "should fetch remote git and analyze" do
      path = Rails.root.join("builds/flyerhzm@gmail.com/railsbp.com/commit/987654321").to_s
      File.expects(:exist?).with(path).returns(false)
      FileUtils.expects(:mkdir_p).with(path)
      FileUtils.expects(:cd).with(path)
      Git.expects(:clone).with("git://github.com/flyerhzm/railsbp.com.git", "railsbp.com")
      rails_best_practices = mock
      RailsBestPractices::Analyzer.expects(:new).with(path, 'format' => 'html', 'silent' => true, 'output-file' => path + "/rbp.html").returns(rails_best_practices)
      rails_best_practices.expects(:analyze)
      rails_best_practices.expects(:output)
      FileUtils.expects(:rm_rf).with(path + "/railsbp.com")
      work_off
    end
  end
end
