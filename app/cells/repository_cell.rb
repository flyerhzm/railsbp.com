class RepositoryCell < Cell::Rails

  def tabs(active_class_name, repository)
    @active_class_name, @repository = active_class_name, repository
    render
  end

  def configurations_form(repository)
    @repository = repository
    @categories = Category.includes(:configurations => :parameters).all
    @configs = RepositoryConfigs.new(@repository).read
    render
  end

  def public
    @repositories = Repository.visible.where("builds_count > 0").order("last_build_at desc").limit(10)
    render
  end

end
