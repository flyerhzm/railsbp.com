class ConfiguresController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_repository

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
