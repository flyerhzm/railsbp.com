class BuildsController < ApplicationController
  before_filter :load_repository
  before_filter :check_allow_builds_count, only: [:index]

  def index
    if params[:position]
      @build = @repository.builds.where(:position => params[:position]).first
      redirect_to repository_build_path(@repository, @build) and return
    end
    @builds = @repository.builds.order("id desc").limit(count)
  end

  def show
    @build = @repository.builds.find(params[:id])
  end

  protected
    def count
      params[:count] || 10
    end

    def load_repository
      @repository = Repository.find(params[:repository_id])
    end

    def check_allow_builds_count
      if @repository.owner.allow_builds_count < count
        flash[:error] = "Your current plan can only view last #{@repository.owner.allow_builds_count} builds, please upgrade your plan."
        redirect_to plans_path
        return false
      end
    end
end
