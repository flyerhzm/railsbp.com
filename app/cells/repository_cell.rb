class RepositoryCell < Cell::Rails

  def configurations_form(repository)
    @repository = repository
    @categories = Category.includes(:configurations => :parameters).all
    @configs = RepositoryConfigs.new(@repository).read
    render
  end

end
