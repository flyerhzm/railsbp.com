class RepositoriesController < ApplicationController
  before_filter :authenticate_user!, except: :sync
  before_filter :set_current_user, only: [:create]
  before_filter :load_repository, only: [:show, :edit, :update]
  respond_to :json, :html

  def index
    if current_user.sync_repos?
      respond_with(current_user.repositories)
    else
      respond_with(error: "not_ready")
    end
  end

  def show
    set_current_repository(@repository)
  end

  def new
    @repository = Repository.new
  end

  def create
    @repository = current_user.add_repository(params[:repository][:github_name])
    if @repository.valid?
      redirect_to @repository
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @repository.update_attributes(params[:repository])
      redirect_to [:edit, @repository]
    else
      @configs = RepositoryConfigs.new(@repository).read
      render :edit
    end
  end

  def sync
    render text: "not authenticate" and return if params[:token].blank?

    payload = ActiveSupport::JSON.decode(params[:payload])
    repository = Repository.where(html_url: payload["repository"]["url"]).first
    render text: "not authenticate" and return unless repository
    render text: "not authenticate" and return unless repository.authentication_token == params["token"]

    if payload["ref"] =~ /#{repository.branch}$/
      repository.generate_build(payload["commits"].first)
      render text: "success"
    else
      render text: "skip"
    end
  end

  protected
    def load_repository
      @repository = Repository.find(params[:id])
    end
end
