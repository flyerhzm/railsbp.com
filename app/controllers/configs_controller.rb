class ConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_repository

  def edit
  end

  def update
    RepositoryConfigs.new(@repository).write(params[:repository][:configs])
    redirect_to [:edit, @repository, :configs], notice: "Update configurations successfully"
  end

  protected
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end
