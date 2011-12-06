class RepositoriesController < ApplicationController
  before_filter :authenticate_user!, except: :sync
  before_filter :set_current_user, only: :create
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
    @build = @repository.builds.last
  end

  def new
    @repository = Repository.new
  end

  def create
    @repository = current_user.repositories.create(params[:repository])
    if @repository.valid?
      redirect_to repository_path(@repository)
    else
      render action: :new
    end
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def sync
    payload = ActiveSupport::JSON.decode(params[:payload])
    repository = Repository.where(html_url: payload["repository"]["url"]).first
    repository.generate_build(payload["commits"].first)
    render text: "success"
  end
end
