require 'rails_helper'

RSpec.describe BuildsController, type: :controller do
  before do
    skip_repository_callbacks
    @user = create(:user)
    @repository = create(:repository)
    @repository.users << @user
  end

  let(:build) { create(:build, repository: @repository) }

  context "GET :index" do
    context "without position" do
      it "should assign builds" do
        get :index, repository_id: build.repository_id

        expect(response).to be_ok
        expect(assigns(:repository)).not_to be_nil
        expect(assigns(:builds)).not_to be_nil
      end
    end

    context "with position" do
      it "should redirect to show" do
        get :index, repository_id: build.repository_id, position: 1

        expect(response).to redirect_to(repository_build_path(build.repository, build))
      end
    end
  end

  context "GET :show" do
    it "should assign build" do
      get :show, id: build.id, repository_id: build.repository_id

      expect(response).to be_ok
      expect(assigns(:repository)).not_to be_nil
      expect(assigns(:build)).not_to be_nil
    end
  end
end
