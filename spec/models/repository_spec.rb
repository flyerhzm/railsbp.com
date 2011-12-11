require 'spec_helper'

describe Repository do
  include FakeFS::SpecHelpers

  it { should have_many(:builds) }

  before do
    FakeFS do
      FileUtils.mkdir_p(Rails.root.join("config"))
      File.open(Rails.root.join("config/rails_best_practices.yml"), "w") { |f|
        f.write "RemoveUnusedMethods: {}\n"
      }
      User.current = Factory(:user)
      @repository = Factory(:repository,
                      github_name: "flyerhzm/railsbp.com",
                      git_url: "git://github.com/flyerhzm/rails-bestpractices.com.git",
                      ssh_url: "git@github.com:flyerhzm/railsbp.com.git"
                    )
    end
  end
  after { FakeFS.deactivate! }
  subject { @repository }

  context "#generate_build" do
    it "should create a build" do
      lambda { subject.generate_build("id" => "987654321", "message" => "commit message") }.should change(subject.builds, :count).by(1)
    end
  end

  context "#clone_url" do
    context "private" do
      subject { @repository.tap { |repository| repository.update_attribute(:private, false) } }
      its(:clone_url) { should == "git://github.com/flyerhzm/rails-bestpractices.com.git" }
    end

    context "public" do
      subject { @repository.tap { |repository| repository.update_attribute(:private, true) } }
      its(:clone_url) { should == "git@github.com:flyerhzm/railsbp.com.git" }
    end
  end

  context "default_config_file_path" do
    its(:default_config_file_path) { should == Rails.root.join("config/rails_best_practices.yml").to_s }
  end

  context "config_path" do
    its(:config_path) { should == Rails.root.join("builds/flyerhzm/railsbp.com").to_s }
  end

  context "config_file_path" do
    its(:config_file_path) { should == Rails.root.join("builds/flyerhzm/railsbp.com/rails_best_practices.yml").to_s }
  end

  context "copy_config_file" do
    it "should copy rails_best_practices.yml file" do
      File.read(Rails.root.join("builds/flyerhzm/railsbp.com/rails_best_practices.yml").to_s).should ==
        File.read(Rails.root.join("config/rails_best_practices.yml").to_s)
    end
  end

  context "#sync_github" do
    before do
      repo = File.read(Rails.root.join("spec/fixtures/repository.json").to_s)
      stub_request(:get, "https://api.github.com/repos/flyrhzm/railsbp.com").to_return(body: repo)
    end

    subject do
      Delayed::Worker.new.work_off
      @repository.reload
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
