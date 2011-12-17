class HomeController < ApplicationController
  def index
    if user_signed_in? && current_repository
      redirect_to repository_path(current_repository) and return
    end
  end
end
