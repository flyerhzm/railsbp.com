require 'spec_helper'

describe RepositoryCell do
  context "cell rendering" do

    context "rendering configurations_form" do
      let(:user) { Factory(:user) }
      let(:repository) { Factory(:repository) }
      before { User.current = user }
      subject { render_cell(:repository, :configurations_form, repository) }

      it { should have_content("Configurations") }
    end

  end


  context "cell instance" do
    subject { cell(:repository) }

    it { should respond_to(:configurations_form) }
  end
end
