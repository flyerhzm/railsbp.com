class HeaderCell < Cell::Rails
  helper_method :name_with_caret

  def display(user, repository)
    @user = user
    @repository = repository
    @repositories = @user.try(:repositories)
    render
  end

  def name_with_caret(name)
    "#{name}<b class='caret'></b>".html_safe
  end

end
