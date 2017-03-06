require 'rails_helper'

RSpec.describe Repository, type: :model do
  it { is_expected.to have_many(:builds) }
  it { is_expected.to have_many(:user_repositories) }
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_many(:owners) }
  it { is_expected.to validate_presence_of(:github_name) }

  context "stub callbacks" do
    it { is_expected.to validate_uniqueness_of(:github_name) }
    it { is_expected.to validate_uniqueness_of(:github_id) }

    before do
      @owner = create(:user)
      User.current = @owner
      @repository = create(:repository,
                      github_name: "railsbp/railsbp.com",
                      git_url: "git://github.com/railsbp/railsbp.com.git",
                      ssh_url: "git@github.com:railsbp/railsbp.com.git"
                    )
      @repository.owners << @owner
    end
    subject { @repository }

    context "#generate_build" do
      it "should create a build and call analyze" do
        expect_any_instance_of(Build).to receive(:run!)
        expect { subject.generate_build("develop", "id" => "987654321", "message" => "commit message") }.to change(subject.builds, :count).by(1)
      end

      it "should do nothing if commit if nil" do
        expect(subject.generate_build("develop", nil)).to be_nil
      end
    end

    context "#clone_url" do
      context "private" do
        subject { @repository.tap { |repository| repository.update_attribute(:private, false) } }
        describe '#clone_url' do
          subject { super().clone_url }
          it { should == "git://github.com/railsbp/railsbp.com.git" }
        end
      end

      context "public" do
        subject { @repository.tap { |repository| repository.update_attribute(:private, true) } }
        describe '#clone_url' do
          subject { super().clone_url }
          it { should == "git@github.com:railsbp/railsbp.com.git" }
        end
      end
    end

    context "default_config_file_path" do
      describe '#default_config_file_path' do
        subject { super().default_config_file_path }
        it { should == Rails.root.join("config/rails_best_practices.yml").to_s }
      end
    end

    context "config_path" do
      describe '#config_path' do
        subject { super().config_path }
        it { should == Rails.root.join("builds/railsbp/railsbp.com").to_s }
      end
    end

    context "config_file_path" do
      describe '#config_file_path' do
        subject { super().config_file_path }
        it { should == Rails.root.join("builds/railsbp/railsbp.com/rails_best_practices.yml").to_s }
      end
    end

    context "#sync_collaborators" do
      before do
        @flyerhzm = create(:user, github_uid: 66836)
        @scott = create(:user, github_uid: 366)
        @ben = create(:user, github_uid: 149420)
        @repository.users << @flyerhzm
        @repository.users << @scott
        User.current = @flyerhzm
        stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com/collaborators").
          to_return(headers: { "Content-Type": "application/json" }, body: File.new(Rails.root.join("spec/fixtures/collaborators.json")))
        @repository.sync_collaborators
        Delayed::Worker.new.work_off
      end

      subject { @repository.reload }

      it "should include existed user" do
        expect(subject.users).to be_include(@ben)
      end

      it "should include new created user" do
        expect(subject.users).to be_include(User.find_by(github_uid: 10122))
      end
    end

    context "#add_collaborator" do
      before do
        stub_request(:get, "https://api.github.com/users/flyerhzm").
          to_return(headers: { "Content-Type": "application/json" }, body: File.new(Rails.root.join("spec/fixtures/collaborator.json")))
      end

      it "should include new created user and owned by user" do
        @repository.add_collaborator("flyerhzm")
        user = User.find_by(github_uid: 66836)
        expect(@repository.users).to be_include(user)
        expect(@repository.owners).to eq [@owner]
      end
    end

    context "#delete_collaborator" do
      before do
        @flyerhzm = create(:user, github_uid: 66836)
        @repository.users << @flyerhzm
      end

      it "should delete a collaborator" do
        expect(@repository.users.size).to eq 2
        @repository.delete_collaborator(@flyerhzm.id)
        expect(@repository.users.size).to eq 1
        expect(@repository.users).not_to be_include(@flyerhzm)
      end
    end

    context "#collaborator_ids" do
      before do
        @flyerhzm = create(:user, github_uid: 66836)
        @scott = create(:user, github_uid: 366)
        @ben = create(:user, github_uid: 149420)
        @repository.users << @flyerhzm
        @repository.users << @scott
      end

      describe '#collaborator_ids' do
        subject { super().collaborator_ids }
        it { should == [@owner.id, @flyerhzm.id, @scott.id] }
      end
    end

    context "#recipient_emails" do
      before do
        @user1 = create(:user, email: "user1@gmail.com")
        @user2 = create(:user, email: "user2@gmail.com")
        @fake_user = create(:user, email: "user@fakemail.com")
        @repository = create(:repository)
        @repository.users << @user1
        @repository.users << @user2
        @repository.users << @fake_user
      end

      it "should return non fakemail.com users" do
        expect(@repository.recipient_emails).to match_array ["user1@gmail.com", "user2@gmail.com"]
      end
    end
  end

  context "#copy_config_file" do
    before { allow_any_instance_of(Repository).to receive(:copy_config_file).and_call_original }
    it "should copy config file if config path exists" do
      repository = build(:repository)
      expect(File).to receive(:exist?).with(repository.config_path).and_return(true)
      expect(FileUtils).to receive(:cp).with(repository.default_config_file_path, repository.config_file_path)
      repository.save
    end

    it "should create config path and copy config file if config path does not exist" do
      repository = build(:repository)
      expect(File).to receive(:exist?).with(repository.config_path).and_return(false)
      expect(FileUtils).to receive(:mkdir_p).with(repository.config_path)
      expect(FileUtils).to receive(:cp).with(repository.default_config_file_path, repository.config_file_path)
      repository.save
    end
  end

  context "#reset_authentication_token" do
    before { allow_any_instance_of(Repository).to receive(:reset_authentication_token).and_call_original }
    subject { create(:repository) }
    describe '#authentication_token' do
      subject { super().authentication_token }
      it { is_expected.not_to be_nil }
    end
  end

  context "#sync_github" do
    before do
      allow_any_instance_of(Repository).to receive(:sync_github).and_call_original
      stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com").
        to_return(headers: { "Content-Type": "application/json" }, body: File.new(Rails.root.join("spec/fixtures/repository.json")))
    end

    subject { create(:repository, github_name: "railsbp/railsbp.com") }

    describe '#html_url' do
      subject { super().html_url }
      it { should == "https://github.com/railsbp/railsbp.com" }
    end
    describe '#git_url' do
      subject { super().git_url }
      it { should == "git://github.com/railsbp/railsbp.com.git" }
    end
    describe '#ssh_url' do
      subject { super().ssh_url }
      it { should == "git@github.com:railsbp/railsbp.com.git" }
    end
    describe '#name' do
      subject { super().name }
      it { should == "railsbp.com" }
    end
    describe '#description' do
      subject { super().description }
      it { should == "railsbp.com" }
    end
    describe '#private' do
      subject { super().private }
      it { is_expected.to be_truthy }
    end
    describe '#fork' do
      subject { super().fork }
      it { is_expected.to be_falsey }
    end
    describe '#github_id' do
      subject { super().github_id }
      it { should == 2860164 }
    end
    describe '#visible' do
      subject { super().visible }
      it { is_expected.to be_falsey }
    end
  end

  context "#setup_github_hook" do
    before { allow_any_instance_of(Repository).to receive(:setup_github_hook).and_call_original }

    it "should call github" do
      stub_request(:post, "https://api.github.com/repos/railsbp/railsbp.com/hooks").
        with(body: {name: "railsbp", config: { railsbp_url: "http://railsbp.com", token:"123456789" }, events: ["push"], active: true})
      create(:repository, github_name: "railsbp/railsbp.com", authentication_token: "123456789")
    end
  end
end
