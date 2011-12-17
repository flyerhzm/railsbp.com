class BuildsController < ApplicationController
  before_filter :load_repository

  def index
    @builds = @repository.builds.order("id desc")
    @h = LazyHighCharts::HighChart.new('graph') do |f|
      f.options[:chart][:defaultSeriesType] = "area"
      f.series(:name=>'Builds', :data => @builds.map(&:warning_count))
    end
  end

  def show
    @build = @repository.builds.find(params[:id])
  end

  protected
    def load_repository
      @repository = Repository.find(params[:repository_id])
    end
end
