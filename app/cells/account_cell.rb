class AccountCell < Cell::Rails

  def tabs(active_class_name)
    @active_class_name = active_class_name
    render
  end

end
