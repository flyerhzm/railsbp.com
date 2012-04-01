class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_repository

  def index
    @collaborators = @repository.users
  end

  def create
    @repository.add_collaborator(params[:collaborator])
    redirect_to [@repository, :collaborators], notice: "Add collaborator successfully"
  end

  def sync
    @repository.sync_collaborators
    redirect_to [@repository, :collaborators], notice: "Synchronizing collaborators is in process, please refresh in a few minutes"
  end

  def destroy
    @repository.delete_collaborator(params[:id])
    redirect_to [@repository, :collaborators], notice: "Delete collaborator successfully"
  end

  protected
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end
