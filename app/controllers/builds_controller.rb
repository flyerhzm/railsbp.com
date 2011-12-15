class BuildsController < ApplicationController
  before_filter :load_repository

  def index
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
