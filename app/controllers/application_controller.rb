class ApplicationController < ActionController::Base
  before_filter :set_current_user
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/', alert: exception.message
  end

  rescue_from UserNoEmailException do |exception|
    redirect_to edit_user_registration_path, alert: "Your must input your email before creating a repository! It is only used to receive notification."
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

  protected
    def render_404(exception = nil)
      if exception
        logger.info "Rendering 404 with exception: #{exception.message}"
      end

      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/404", :formats => [:html], :status => :not_found, :layout => false }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end

    def render_422(exception = nil)
      if exception
        logger.info "Rendering 422 with exception: #{exception.message}"
      end

      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/422", :formats => [:html], :status => :unprocessable_entity, :layout => false }
        format.xml  { header :unprocessable_entity }
        format.any  { header :unprocessable_entity }
      end
    end
end
