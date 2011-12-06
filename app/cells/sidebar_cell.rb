class SidebarCell < Cell::Rails

  def repositories(user)
    @user = user
    @private_repositories = @user.repositories
    @public_repositories = Repository.limit(10).order("updated_at desc")
    render
  end

end
