require 'spec_helper'

describe BuildsController do
  context "GET :index" do
    before do
      Repository.any_instance.stubs(:sync_github).returns(true)
      build = Factory(:build)
      get :index, repository_id: build.repository_id
    end

    it "should assign builds" do
      response.should be_ok
      assigns(:repository).should_not be_nil
      assigns(:builds).should_not be_nil
    end
  end

  context "GET :show" do
    before do
      Repository.any_instance.stubs(:sync_github).returns(true)
      build = Factory(:build)
      get :show, id: build.id, repository_id: build.repository_id
    end

    it "should assign build" do
      response.should be_ok
      assigns(:repository).should_not be_nil
      assigns(:build).should_not be_nil
    end
  end
end
