require 'rails_helper'

RSpec.describe CollaboratorsController, type: :controller do
  before do
    skip_repository_callbacks
    @repository = create(:repository)

    user = create(:user)
    sign_in user
  end

  context "GET :index" do
    it "should list all collaborators" do
      collaborator1 = create(:user)
      collaborator2 = create(:user)
      @repository.users << collaborator1
      @repository.users << collaborator2

      get :index, repository_id: @repository.id
      expect(response).to be_ok
      expect(assigns(:collaborators)).to eq [collaborator1, collaborator2]
    end
  end
end
