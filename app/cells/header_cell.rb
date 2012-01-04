class HeaderCell < Cell::Rails

  def display(user, repository)
    @user = user
    @repository = repository
    @repositories = @user.repositories.visible if @user.present?
    @repository = @repositories.first if @repository.nil? && @repositories.present?
    render
  end

end
