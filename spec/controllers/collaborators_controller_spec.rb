require 'spec_helper'

describe CollaboratorsController do
  before do
    Repository.any_instance.stubs(:sync_github).returns(true)
    Repository.any_instance.stubs(:set_privacy).returns(true)
    @repository = Factory(:repository)

    user = Factory(:user)
    sign_in user
  end

  context "GET :index" do
    it "should list all collaborators" do
      collaborator1 = Factory(:user)
      collaborator2 = Factory(:user)
      @repository.users << collaborator1
      @repository.users << collaborator2

      get :index, repository_id: @repository.id
      response.should be_ok
      assigns(:collaborators).should == [collaborator1, collaborator2]
    end
  end
end
