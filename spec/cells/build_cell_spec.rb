require 'spec_helper'

describe BuildCell do
  before { Repository.any_instance.stubs(:sync_github) }
  context "cell rendering" do
    context "rendering tabs" do
      let(:user) { Factory(:user) }
      let(:repository) { Factory(:repository) }
      let(:build) { Factory(:build, :repository => repository) }
      before { User.current = user }

      context "current" do
        subject { render_cell(:build, :tabs, "current", repository) }

        it { should have_link("Edit") }
        it { should have_selector("li.active", :content => "Current") }
      end

      context "history" do
        subject { render_cell(:build, :tabs, "history", repository) }

        it { should have_link("Edit") }
        it { should have_selector("li.active", :content => "Current") }
      end

      context "build" do
        subject { render_cell(:build, :tabs, "history", repository, build) }

        it { should have_link("Edit") }
        it { should have_selector("li.active", :content => "Build") }
      end
    end

    context "rendering content" do
      let(:user) { Factory(:user) }
      let(:repository) { Factory(:repository) }
      let(:build) { Factory(:build, :repository => repository, :warning_count => 10).tap { |build| build.run!; build.complete! } }
      before do
        User.current = user
        File.stubs(:read).returns("")
      end

      context "repository with build" do
        subject { render_cell(:build, :content, repository, build) }

        it { should have_content("Analyze Result") }
        it { should have_content("Warning count: 10") }
      end

      context "repository without build" do
        subject { render_cell(:build, :content, repository) }

        it { should_not have_content("Analyze Result") }
      end

      context "build" do
      end
    end
  end


  context "cell instance" do
    subject { cell(:build) }

    it { should respond_to(:tabs) }
    it { should respond_to(:content) }
  end
end
