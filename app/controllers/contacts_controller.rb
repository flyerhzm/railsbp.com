class ContactsController < ApplicationController
  def new
    @contact = Contact.new
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
