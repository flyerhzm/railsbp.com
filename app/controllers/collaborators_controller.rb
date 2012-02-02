class CollaboratorsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_repository
  before_filter :check_allow_collaborators_count, only: [:create]
  before_filter :check_sync_collaborators_count, only: [:sync]

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
    user = User.find(params[:id])
    @repository.users.destroy(user)
    redirect_to [@repository, :collaborators], notice: "Delete collaborator successfully"
  end

  protected
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def check_allow_collaborators_count
      if current_user.allow_collaborators_count <= @repository.collaborators_count
        flash[:error] = "Your current plan can only create #{current_user.allow_collaborators_count} collaborators, please upgrade your plan."
        redirect_to plans_path
        return false
      end
      true
    end

    def check_sync_collaborators_count
      client = Octokit::Client.new(oauth_token: current_user.github_token)
      github_collaborators = client.collaborators(@repository.github_name)
      total_count = github_collaborators.count
      existing_count = @repository.users.where(github_uid: github_collaborators.map(&:id)).count
      if current_user.allow_collaborators_count <= @repository.collaborators_count + total_count - existing_count
        flash[:error] = "Your current plan can only create #{current_user.allow_collaborators_count} collaborators, please upgrade your plan."
        redirect_to plans_path
        return false
      end
    end
end
