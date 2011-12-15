class ApplicationController < ActionController::Base
  helper_method :current_repository
  protect_from_forgery

  def set_current_user
    User.current = current_user
  end

  def current_repository
    Repository.find(session[:repository_id]) if session[:repository_id]
  end

  def set_current_repository(repository)
    session[:repository_id] = repository.id
  end
end
