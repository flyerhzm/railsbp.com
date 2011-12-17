require 'spec_helper'

describe BuildCell do
  context "cell rendering" do
    context "rendering tabs" do
      let(:user) { Factory(:user) }
      let(:repository) { Factory(:repository) }
      let(:build) { Factory(:build, :repository => repository) }
      before { User.current = user }

      context "current" do
        subject { render_cell(:build, :tabs, "current", repository) }

        it { should have_link("Configure") }
        it { should have_selector("li.active", :content => "Current") }
      end

      context "history" do
        subject { render_cell(:build, :tabs, "history", repository) }

        it { should have_link("Configure") }
        it { should have_selector("li.active", :content => "Current") }
      end

      context "Build" do
        subject { render_cell(:build, :tabs, "history", repository, build) }

        it { should have_link("Configure") }
        it { should have_selector("li.active", :content => "Build") }
      end
    end

    context "rendering content" do
      subject { render_cell(:build, :content) }

      it { should have_selector("h1", :content => "Build#content") }
      it { should have_selector("p", :content => "Find me in app/cells/build/content.html") }
    end

  end


  context "cell instance" do
    subject { cell(:build) }

    it { should respond_to(:tabs) }
    it { should respond_to(:content) }
  end
end
