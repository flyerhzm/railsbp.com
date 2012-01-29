class HeaderCell < Cell::Rails

  def display(user, repository)
    @user = user
    @repository = repository
    @repositories = @user.try(:repositories)
    render
  end

end
