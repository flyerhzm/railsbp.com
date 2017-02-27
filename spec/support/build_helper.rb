module Support
  module BuildHelper
    def build_analyze_success
      allow_any_instance_of(Build).to receive(:system)
      allow(Dir).to receive(:chdir)
      allow_any_instance_of(Build).to receive(:last_errors).and_return([])
      allow_any_instance_of(Build).to receive(:current_errors).and_return([])
      mailer = double(:mailer)
      allow(mailer).to receive(:deliver)
      allow(UserMailer).to receive(:notify_build_success).and_return(mailer)
      allow(File).to receive(:open)
      work_off
    end

    def build_analyze_failure
      allow_any_instance_of(Build).to receive(:system)
      allow(Dir).to receive(:chdir).and_raise
      allow(Rollbar).to receive(:error)
      work_off
    end
  end
end
