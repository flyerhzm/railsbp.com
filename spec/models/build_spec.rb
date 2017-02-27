require 'rails_helper'

RSpec.describe Build, type: :model do
  it { is_expected.to belong_to(:repository) }

  before { skip_repository_callbacks }

  context "#short_commit_id" do
    subject { create(:build, :last_commit_id => "1234567890") }
    describe '#short_commit_id' do
      subject { super().short_commit_id }
      it { should == "1234567" }
    end
  end

  context "#analyze_path" do
    before do
      @repository = create(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    describe '#analyze_path' do
      subject { super().analyze_path }
      it { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321").to_s }
    end
  end

  context "#html_output_file" do
    before do
      @repository = create(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    describe '#html_output_file' do
      subject { super().html_output_file }
      it { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/rbp.html").to_s }
    end
  end

  context "#yaml_output_file" do
    before do
      @repository = create(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    describe '#yaml_output_file' do
      subject { super().yaml_output_file }
      it { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/rbp.yml").to_s }
    end
  end

  context "#template_file" do
    subject { @build = create(:build) }
    describe '#template_file' do
      subject { super().template_file }
      it { should == Rails.root.join("app/views/builds/rbp.html.erb").to_s }
    end
  end

  context "#run!" do
    before do
      repository = create(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.run!
    end

    it "should fetch remote git and analyze" do
      build_analyze_success

      @build.reload
      expect(@build.aasm_state).to eq "completed"
    end

    it "should fail" do
      build_analyze_failure

      @build.reload
      expect(@build.aasm_state).to eq "failed"
    end
  end

  context "#rerun!" do
    before do
      repository = create(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
      @build = repository.builds.create(last_commit_id: "987654321")
      @build.aasm_state = "failed"
      @build.save
      @build.rerun!
    end

    it "should fetch remote git and analyze" do
      build_analyze_success

      @build.reload
      expect(@build.aasm_state).to eq "completed"
    end
  end

  context "config_directory_path" do
    before do
      @repository = create(:repository, github_name: "flyerhzm/railsbp.com", name: "railsbp.com", git_url: "git://github.com/flyerhzm/railsbp.com.git")
    end
    subject { @build = @repository.builds.create(last_commit_id: "987654321") }
    describe '#config_directory_path' do
      subject { super().config_directory_path }
      it { should == Rails.root.join("builds/flyerhzm/railsbp.com/commit/987654321/railsbp.com/config/").to_s }
    end
  end
end
