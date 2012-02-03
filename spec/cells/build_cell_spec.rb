require 'spec_helper'

describe BuildCell do
  before do
    Repository.any_instance.stubs(:sync_github)
    Repository.any_instance.stubs(:set_privacy)
  end
  context "cell rendering" do
    context "rendering tabs" do
      let(:repository) { Factory(:repository) }
      let(:build) { Factory(:build, :repository => repository) }

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

    context "rendering history_links" do
      let(:repository) { Factory(:repository) }

      context "last 10" do
        subject { render_cell(:build, :history_links, repository, 10) }

        it { should have_selector("a.active", :content => "Last 10 Builds") }
      end

      context "last 50" do
        subject { render_cell(:build, :history_links, repository, 50) }

        it { should have_selector("a.active", :content => "Last 50 Builds") }
      end

      context "last 100" do
        subject { render_cell(:build, :history_links, repository, 100) }

        it { should have_selector("a.active", :content => "Last 100 Builds") }
      end
    end

    context "rendering content" do
      let(:repository) { Factory(:repository) }
      let(:build) { Factory(:build, :repository => repository, :warning_count => 10).tap { |build| build.run!; build.complete! } }
      before do
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
    it { should respond_to(:history_links) }
    it { should respond_to(:content) }
  end
end
