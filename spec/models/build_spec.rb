require 'spec_helper'

describe Build do
  it { should belong_to(:repository) }

  before { skip_repository_callbacks }

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

  context "#html_output_file" do
    before do
      @repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    its(:html_output_file) { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/rbp.html").to_s }
  end

  context "#yaml_output_file" do
    before do
      @repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    its(:yaml_output_file) { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/rbp.yml").to_s }
  end

  context "#template_file" do
    subject { @build = Factory(:build) }
    its(:template_file) { should == Rails.root.join("app/views/builds/rbp.html.erb").to_s }
  end

  context "#run!" do
    before do
      repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.run!
    end

    it "should fetch remote git and analyze" do
      build_analyze_success

      @build.reload
      @build.aasm_state.should == "completed"
    end

    it "should fail" do
      build_analyze_failure

      @build.reload
      @build.aasm_state.should == "failed"
    end
  end

  context "#rerun!" do
    before do
      repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.aasm_state = "failed"
      @build.save
      @build.rerun!
    end

    it "should fetch remote git and analyze" do
      build_analyze_success

      @build.reload
      @build.aasm_state.should == "completed"
    end
  end

  context "#proxy_analyze" do
    before do
      repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.warnings = [{"short_filename" => "app/models/user.rb", "line_number" => "10", "message" => "use scope", "type" => "RailsBestPractices::Review::UseScope", "git_commit" => "1234567890", "git_usernmae" => "richard"}]
      @build.stubs(:last_errors).returns({})
      @build.proxy_analyze
    end

    it "should analyze proxy" do
      File.exist?(@build.html_output_file)
    end

    it "should be completed state" do
      @build.aasm_state.should == "completed"
    end
  end

  context "config_directory_path" do
    before do
      @repository = Factory(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    its(:config_directory_path) { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/railsbp.com/config/").to_s }
  end
end
