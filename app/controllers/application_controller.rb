class ApplicationController < ActionController::Base
  protect_from_forgery

  def set_current_user
    User.current = current_user
  end
end
