class BuildCell < Cell::Rails

  def tabs(active_class_name, repository, build=nil)
    @active_class_name, @repository, @build = active_class_name, repository, build
    render
  end

  def content
    render
  end

end
