class PlansController < ApplicationController
  before_filter :authenticate_user!

  def index
    @plans = Plan.visible.order("amount desc")
  end
end
