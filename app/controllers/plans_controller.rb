class PlansController < ApplicationController
  before_filter :authenticate_user!

  def index
    @plans = Plan.order("amount desc")
  end
end
