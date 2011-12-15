class HeaderCell < Cell::Rails

  def display(user)
    @user = user
    @repositories = @user.try(:repositories)
    render
  end

end
