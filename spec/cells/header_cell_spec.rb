require 'spec_helper'

describe HeaderCell do
  before { skip_repository_callbacks }

  context "cell rendering" do
    context "rendering display without current_user" do
      subject { render_cell(:header, :display, nil, nil) }

      it { should have_link("Home") }
      it { should have_link("About") }
      it { should have_link("Contact") }
      it { should have_link("Sign in with Github") }
      it { should_not have_link("Projects") }
    end

    context "rendering display with current_user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:repository) { FactoryGirl.create(:repository) }
      subject { render_cell(:header, :display, user, repository) }

      it { should have_link("Home") }
      it { should have_link("About") }
      it { should have_link("Contact") }
      it { should have_link(repository.name) }
      it { should have_link("Create Repository") }
      it { should have_link("Sign out") }
    end
  end

  context "cell instance" do
    subject { cell(:header) }

    it { should respond_to(:display) }
  end
end
