require 'spec_helper'

describe Repository do
  it { should have_many(:builds) }
  it { should have_many(:user_repositories) }
  it { should have_many(:users) }
  it { should have_many(:owners) }
  it { should validate_presence_of(:github_name) }

  context "stub callbacks" do
    it { should validate_uniqueness_of(:github_name) }
    it { should validate_uniqueness_of(:github_id) }

    before do
      skip_repository_callbacks
      @owner = Factory(:user)
      User.current = @owner
      @repository = Factory(:repository,
                      github_name: "railsbp/railsbp.com",
                      git_url: "git://github.com/railsbp/railsbp.com.git",
                      ssh_url: "git@github.com:railsbp/railsbp.com.git"
                    )
      @repository.owners << @owner
    end
    subject { @repository }

    context "#generate_build" do
      it "should create a build and call analyze" do
        Build.any_instance.expects(:run!)
        lambda { subject.generate_build("develop", "id" => "987654321", "message" => "commit message") }.should change(subject.builds, :count).by(1)
      end
    end

    context "#generate_proxy_build" do
      it "should create a build and call proxy_analyze" do
        Build.any_instance.expects(:proxy_analyze)
        lambda { subject.generate_proxy_build("develop", {"id" => "987654321", "message" => "commit message"}, []) }.should change(subject.builds, :count).by(1)
      end
    end

    context "#clone_url" do
      context "private" do
        subject { @repository.tap { |repository| repository.update_attribute(:private, false) } }
        its(:clone_url) { should == "git://github.com/railsbp/railsbp.com.git" }
      end

      context "public" do
        subject { @repository.tap { |repository| repository.update_attribute(:private, true) } }
        its(:clone_url) { should == "git@github.com:railsbp/railsbp.com.git" }
      end
    end

    context "default_config_file_path" do
      its(:default_config_file_path) { should == Rails.root.join("config/rails_best_practices.yml").to_s }
    end

    context "config_path" do
      its(:config_path) { should == Rails.root.join("builds/railsbp/railsbp.com").to_s }
    end

    context "config_file_path" do
      its(:config_file_path) { should == Rails.root.join("builds/railsbp/railsbp.com/rails_best_practices.yml").to_s }
    end

    context "#sync_collaborators" do
      before do
        @flyerhzm = Factory(:user, github_uid: 66836)
        @scott = Factory(:user, github_uid: 366)
        @ben = Factory(:user, github_uid: 149420)
        @repository.users << @flyerhzm
        @repository.users << @scott
        User.current = @flyerhzm
        collaborators = File.read(Rails.root.join("spec/fixtures/collaborators.json").to_s)
        stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com/collaborators").to_return(body: collaborators)
        @repository.sync_collaborators
        Delayed::Worker.new.work_off
      end

      subject { @repository.reload }

      it "should include existed user" do
        subject.users.should be_include(@ben)
      end

      it "should include new created user" do
        subject.users.should be_include(User.find_by_github_uid(10122))
      end
    end

    context "#add_collaborator" do
      before do
        collaborator = File.read(Rails.root.join("spec/fixtures/collaborator.json").to_s)
        stub_request(:get, "https://api.github.com/users/flyerhzm").to_return(body: collaborator)
      end

      it "should include new created user and owned by user" do
        @repository.add_collaborator("flyerhzm")
        user = User.find_by_github_uid(66836)
        @repository.users.should be_include(user)
        @repository.owners.should == [@owner]
      end
    end

    context "#delete_collaborator" do
      before do
        @flyerhzm = Factory(:user, github_uid: 66836)
        @repository.users << @flyerhzm
      end

      it "should delete a collaborator" do
        @repository.should have(2).users
        @repository.delete_collaborator(@flyerhzm.id)
        @repository.should have(1).users
        @repository.users.should_not be_include(@flyerhzm)
      end
    end

    context "#collaborator_ids" do
      before do
        @flyerhzm = Factory(:user, github_uid: 66836)
        @scott = Factory(:user, github_uid: 366)
        @ben = Factory(:user, github_uid: 149420)
        @repository.users << @flyerhzm
        @repository.users << @scott
      end

      its(:collaborator_ids) { should == [@owner.id, @flyerhzm.id, @scott.id] }
    end

    context "#recipient_emails" do
      before do
        @user1 = Factory(:user, email: "user1@gmail.com")
        @user2 = Factory(:user, email: "user2@gmail.com")
        @fake_user = Factory(:user, email: "user@fakemail.com")
        @repository = Factory(:repository)
        @repository.users << @user1
        @repository.users << @user2
        @repository.users << @fake_user
      end

      it "should return non fakemail.com users" do
        @repository.recipient_emails.should == ["user1@gmail.com", "user2@gmail.com"]
      end
    end
  end

  context "#copy_config_file" do
    before { skip_repository_callbacks(:except => :copy_config_file) }
    it "should copy config file if config path exists" do
      repository = Factory.build(:repository)
      File.expects(:exist?).with(repository.config_path).returns(true)
      FileUtils.expects(:cp).with(repository.default_config_file_path, repository.config_file_path)
      repository.save
    end

    it "should create config path and copy config file if config path does not exist" do
      repository = Factory.build(:repository)
      File.expects(:exist?).with(repository.config_path).returns(false)
      FileUtils.expects(:mkdir_p).with(repository.config_path)
      FileUtils.expects(:cp).with(repository.default_config_file_path, repository.config_file_path)
      repository.save
    end
  end

  context "#reset_authentication_token" do
    before { skip_repository_callbacks(:except => :reset_authentication_token) }
    subject { Factory(:repository) }
    its(:authentication_token) { should_not be_nil }
  end

  context "#sync_github" do
    before do
      skip_repository_callbacks(:except => :sync_github)
      repo = File.read(Rails.root.join("spec/fixtures/repository.json").to_s)
      stub_request(:get, "https://api.github.com/repos/railsbp/railsbp.com").to_return(body: repo)
    end

    subject { Factory(:repository, github_name: "railsbp/railsbp.com") }

    its(:html_url) { should == "https://github.com/railsbp/railsbp.com" }
    its(:git_url) { should == "git://github.com/railsbp/railsbp.com.git" }
    its(:ssh_url) { should == "git@github.com:railsbp/railsbp.com.git" }
    its(:name) { should == "railsbp.com" }
    its(:description) { should == "railsbp.com" }
    its(:private) { should be_true }
    its(:fork) { should be_false }
    its(:github_id) { should == 2860164 }
    its(:visible) { should be_false }
  end

  context "#setup_github_hook" do
    before do
      skip_repository_callbacks(:except => :setup_github_hook)
    end

    it "should call github" do
      stub_request(:post, "https://api.github.com/repos/railsbp/railsbp.com/hooks").
        with(body: {name: "railsbp", config: { railsbp_url: "http://railsbp.com", token:"1234567890" }, events: ["push"], active: true})
      Factory(:repository, github_name: "railsbp/railsbp.com", authentication_token: "1234567890")
    end
  end
end
