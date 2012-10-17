class RepositoriesController < ApplicationController
  load_and_authorize_resource except: [:sync, :sync_proxy]
  before_filter :authenticate_user!, except: [:show, :sync, :sync_proxy]
  before_filter :load_repository, only: [:show, :edit, :update]
  before_filter :force_input_email, only: [:new, :create]

  def show
  end

  def new
    @repository = Repository.new
  end

  def create
    @repository = current_user.add_repository(params[:repository][:github_name])
    if @repository.valid?
      redirect_to [:edit, @repository], notice: "Repository created successfully."
    else
      render :new
    end
  rescue Octokit::NotFound
    flash[:error] = "There is no such repository or you don't have access to such repository on githbub"
    redirect_to action: :new
  rescue AuthorizationException => e
    flash[:error] = e.message
    redirect_to [:new, :repository]
  end

  def edit
  end

  def update
    if @repository.update_attributes(params[:repository])
      redirect_to [:edit, @repository], notice: "Repository updated successfully."
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
    if repository.private?
      repository.notify_privacy
      render text: "no private repository" and return
    elsif !repository.rails?
      render text: "not rails repository" and return
    end

    repository.generate_build(payload["ref"].split("/").last, payload["commits"].last)
    render text: "success"
  end

  protected
    def load_repository
      @repository = Repository.find(params[:id])
    end

    def force_input_email
      raise UserNoEmailException if current_user.fakemail?
    end
end
