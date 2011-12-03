class RepositoriesController < ApplicationController
  before_filter :authenticate_user!, :only => :index
  respond_to :json, :html

  def index
    if current_user.sync_repos?
      respond_with(current_user.repositories)
    else
      respond_with(error: "not_ready")
    end
  end

  def show
    @repository = Repository.find(params[:id])
  end

  def sync
    payload = ActiveSupport::JSON.decode(params[:payload])
    repository = Repository.where(:html_url => payload["repository"]["url"]).first
    repository.generate_build(:last_commit_id => payload["commits"].first["id"])
    render :text => 'success'
  end
end
