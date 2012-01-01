class ApplicationController < ActionController::Base
  helper_method :current_repository
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to '/'
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_404
  end

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    render_422
  end

  def set_current_user
    User.current = current_user
  end

  def current_repository
    Repository.find(session[:repository_id]) if session[:repository_id]
  end

  def set_current_repository(repository)
    session[:repository_id] = repository.id
  end

  protected
    def render_404(exception = nil)
      if exception
        logger.info "Rendering 404 with exception: #{exception.message}"
      end

      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404.html", :status => :not_found, :layout => false }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end

    def render_422(exception = nil)
      if exception
        logger.info "Rendering 422 with exception: #{exception.message}"
      end

      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
        format.xml  { header :unprocessable_entity }
        format.any  { header :unprocessable_entity }
      end
    end
end
