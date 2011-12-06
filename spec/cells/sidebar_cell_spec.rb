require 'spec_helper'

describe SidebarCell do
  context "cell rendering" do

    context "rendering repositories" do
      before do
        @user = Factory(:user)
      end
      subject { render_cell(:sidebar, :repositories, @user) }
      it { should have_link("Add Project") }
      it { should have_link("My Projects") }
      it { should have_link("Public Projects") }
    end
  end


  context "cell instance" do
    subject { cell(:sidebar) }
    it { should respond_to(:repositories) }
  end
end
