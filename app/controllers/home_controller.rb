class HomeController < ApplicationController
  def index
    current_user.try(:repositories)
  end
end
