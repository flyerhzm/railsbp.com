class HomeController < ApplicationController
  def index
    @repositories = Repository.visible.where("builds_count > 0").order("last_build_at desc").limit(10)
  end
end
