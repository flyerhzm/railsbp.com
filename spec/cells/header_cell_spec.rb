require 'spec_helper'

describe HeaderCell do
  context "cell rendering" do
    context "rendering display without current_user" do
      subject { render_cell(:header, :display, nil) }

      it { should have_selector("h3", :content => "Railsbp") }
      it { should have_link("Home") }
      it { should have_link("About") }
      it { should have_link("Contact") }
      it { should have_link("Sign in with Github") }
      it { should_not have_link("Projects") }
    end

    context "rendering display with current_user" do
      let(:user) { Factory(:user) }
      subject { render_cell(:header, :display, user) }

      it { should have_selector("h3", :content => "Railsbp") }
      it { should have_link("Home") }
      it { should have_link("About") }
      it { should have_link("Contact") }
      it { should have_link("Projects") }
      it { should have_link("New Project") }
      it { should have_link("Sign out") }
    end
  end

  context "cell instance" do
    subject { cell(:header) }

    it { should respond_to(:display) }
  end
end
