require 'spec_helper'

describe Build do
  include DelayedJobSpecHelper

  it { should belong_to(:repository) }

  before do
    Repository.any_instance.stubs(:set_privacy)
    Repository.any_instance.stubs(:sync_github)
  end

  context "#short_commit_id" do
    subject { Factory(:build, :last_commit_id => "1234567890") }
    its(:short_commit_id) { should == "1234567" }
  end

  context "#analyze_path" do
    before do
      @repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    its(:analyze_path) { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321").to_s }
  end

  context "#analyze_file" do
    before do
      @repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    its(:analyze_file) { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/rbp.html").to_s }
  end

  context "#templae_file" do
    subject { @build = Factory(:build) }
    its(:template_file) { should == Rails.root.join("app/views/builds/_rbp.html.erb").to_s }
  end

  context "#analyze" do
    before do
      repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.analyze
    end

    it "should fetch remote git and analyze" do
      path = Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321").to_s
      template = Rails.root.join("app/views/builds/_rbp.html.erb").to_s
      File.expects(:exist?).with(path).returns(false)
      FileUtils.expects(:mkdir_p).with(path)
      FileUtils.expects(:cd).with(path)

      Git.expects(:clone).with("git://github.com/flyerhzm/railsbp.com.git", "railsbp.com", depth: 10)
      Dir.expects(:chdir).with("railsbp.com")

      rails_best_practices = mock
      RailsBestPractices::Analyzer.expects(:new).with(path + "/railsbp.com", "format" => "html", "silent" => true, "output-file" => path + "/rbp.html", "with-github" => true, "github-name" => "flyerhzm/railsbp.com", "last-commit-id" => "987654321", "template" => template).returns(rails_best_practices)
      rails_best_practices.expects(:analyze)
      rails_best_practices.expects(:output)

      runner = mock
      rails_best_practices.expects(:runner).returns(runner)
      runner.expects(:errors).returns([])
      FileUtils.expects(:rm_rf).with(path + "/railsbp.com")
      work_off
    end
  end

  context "#proxy_analyze" do
    before do
      repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.warnings = [{"short_filename" => "app/models/user.rb", "line_number" => "10", "message" => "use scope", "type" => "RailsBestPractices::Review::UseScope"}]
      @build.proxy_analyze
    end

    it "should analyze proxy" do
      File.exist?(@build.analyze_file)
    end
  end

  context "recipients" do
    before do
      @user1 = Factory(:user, email: "user1@gmail.com")
      @user2 = Factory(:user, email: "user2@gmail.com")
      @fake_user = Factory(:user, email: "user@fakemail.com")
      @repository = Factory(:repository)
      @repository.users << @user1
      @repository.users << @user2
      @repository.users << @fake_user
      @build = Factory(:build, repository: @repository)
    end

    it "should return non fakemail.com users" do
      @build.recipient_emails.should == ["user1@gmail.com", "user2@gmail.com"]
    end
  end

  context "config_directory_path" do
    before do
      @repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    its(:config_directory_path) { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/config").to_s }
  end
end
