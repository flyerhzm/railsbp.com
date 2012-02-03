class BuildCell < Cell::Rails

  def tabs(active_class_name, repository, build=nil)
    @active_class_name, @repository, @build = active_class_name, repository, build
    render
  end

  def history_links(repository, builds_count)
    @repository, @builds_count = repository, builds_count
    render
  end

  def content(repository, build=nil)
    @repository, @build = repository, build
    @build ||= @repository.builds.completed.last
    render
  end

end
