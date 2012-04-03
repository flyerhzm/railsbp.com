class ContactsController < ApplicationController
  def new
    @contact = Contact.new
    if current_user
      @contact.name = current_user.name
      @contact.email = current_user.email
    end
  end

  def create
    @contact = Contact.new(params[:contact])

    if @contact.save
      redirect_to new_contact_path, notice: "Contact email was successfully sent."
    else
      flash[:error] = "You must enter both fields."
      render :new
    end
  end
end
