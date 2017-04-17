require 'rails_helper'

RSpec.describe AnalyzeBuildJob do
  let(:repository) { create(:repository, github_name: "railsbp/railsbp.com", name: "railsbp.com", git_url: "git://github.com/railsbp/railsbp.com.git") }
  let(:build) { create(:build, last_commit_id: '987654321', repository: repository, aasm_state: 'running') }

  context "success" do
    before do
      allow_any_instance_of(Kernel).to receive(:system)
      allow(Dir).to receive(:chdir)
      allow_any_instance_of(Build).to receive(:last_errors).and_return([])
      allow_any_instance_of(Build).to receive(:current_errors).and_return([])
      allow(UserMailer).to receive(:notify_build_success).and_return(double(:UserMailer, deliver: true))
      allow(File).to receive(:open)
    end

    it "should fetch remote git and analyze" do
      AnalyzeBuildJob.new.perform(build.id)
      expect(build.reload.aasm_state).to eq "completed"
    end
  end

  context 'failure' do
    before do
      allow_any_instance_of(Build).to receive(:system)
      allow(Dir).to receive(:chdir).and_raise
      allow(Rollbar).to receive(:error)
    end

    it "should fail" do
      AnalyzeBuildJob.new.perform(build.id)
      expect(build.reload.aasm_state).to eq "failed"
    end
  end
end
