require 'spec_helper'

describe RepositoryCell do
  context "cell rendering" do
    before { skip_repository_callbacks }

    context "rendering tabs" do
      subject { render_cell(:repository, :tabs, "configs", create(:repository)) }

      it { should have_link("Overview") }
      it { should have_css("li.active a", :text => "Configurations") }
      it { should have_link("Collaborators") }
    end

    context "rendering configurations_form" do
      let(:repository) { create(:repository) }
      before do
        repository.expects(:config_file_path).returns("/tmp")
        YAML.expects(:load_file).with("/tmp")
      end
      subject { render_cell(:repository, :configurations_form, repository) }

      it { should have_css("form") }
    end

    context "renderding public" do
      before do
        public_repository = create(:repository, name: "public", visible: true)
        private_repository = create(:repository, name: "private", visible: false)
        last_build = create(:build, repository: public_repository, duration: 20)
        last_build.update_attribute(:position, 5)
      end
      subject { render_cell(:repository, :public) }

      it { should have_link("public") }
      it { should_not have_link("private") }
      it { should have_link("#5") }
      it { should have_content("Duration: 20 secs") }
      it { should have_content("Finished: less than a minute ago") }
    end

  end


  context "cell instance" do
    subject { cell(:repository) }

    it { should respond_to(:tabs) }
    it { should respond_to(:configurations_form) }
    it { should respond_to(:public) }
  end
end
