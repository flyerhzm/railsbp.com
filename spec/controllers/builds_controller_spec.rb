require 'spec_helper'

describe BuildsController do
  before do
    skip_repository_callbacks
    @user = FactoryGirl.create(:user)
    @repository = FactoryGirl.create(:repository)
    @repository.users << @user
  end

  let(:build) { FactoryGirl.create(:build, repository: @repository) }

  context "GET :index" do
    context "without position" do
      it "should assign builds" do
        get :index, repository_id: build.repository_id

        response.should be_ok
        assigns(:repository).should_not be_nil
        assigns(:builds).should_not be_nil
      end
    end

    context "with position" do
      it "should redirect to show" do
        get :index, repository_id: build.repository_id, position: 1

        response.should redirect_to(repository_build_path(build.repository, build))
      end
    end
  end

  context "GET :show" do
    it "should assign build" do
      get :show, id: build.id, repository_id: build.repository_id

      response.should be_ok
      assigns(:repository).should_not be_nil
      assigns(:build).should_not be_nil
    end
  end
end
