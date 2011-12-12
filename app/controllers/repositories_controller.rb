class RepositoriesController < ApplicationController
  before_filter :authenticate_user!, except: :sync
  before_filter :set_current_user, only: :create
  before_filter :load_repository, only: [:show, :edit, :update, :update_configs]
  respond_to :json, :html

  def index
    if current_user.sync_repos?
      respond_with(current_user.repositories)
    else
      respond_with(error: "not_ready")
    end
  end

  def show
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
    @configs = RepositoryConfigs.new(@repository).read
  end

  def update
    if @repository.update_attributes(params[:repository])
      redirect_to edit_repository_path(@repository)
    else
      @configs = RepositoryConfigs.new(@repository).read
      render :action => :edit
    end
  end

  def update_configs
    RepositoryConfigs.new(@repository).write(params[:repository][:configs])
    redirect_to edit_repository_path(@repository)
  end

  def sync
    payload = ActiveSupport::JSON.decode(params[:payload])
    repository = Repository.where(html_url: payload["repository"]["url"]).first
    repository.generate_build(payload["commits"].first)
    render text: "success"
  end

  protected
    def load_repository
      @repository = Repository.find(params[:id])
    end
end
