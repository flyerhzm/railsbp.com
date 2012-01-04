class HeaderCell < Cell::Rails

  def display(user, repository)
    @user = user
    @repository = repository
    @repositories = @user.try(:repositories)
    @repository = @repositories.first if @repository.nil? && @repositories.present?
    render
  end

end
