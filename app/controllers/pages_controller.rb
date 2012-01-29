class PagesController < ApplicationController
  def show
    @page = Page.where(name: params[:name]).first
    render_404 unless @page
  end
end
