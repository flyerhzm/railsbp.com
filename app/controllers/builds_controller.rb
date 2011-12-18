class BuildsController < ApplicationController
  before_filter :load_repository

  def index
    if params[:position]
      @build = @repository.builds.where(:position => params[:position]).first
      redirect_to repository_build_path(@repository, @build) and return
    end
    @builds = @repository.builds.order("id desc")
  end

  def show
    @build = @repository.builds.find(params[:id])
  end

  protected
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end
