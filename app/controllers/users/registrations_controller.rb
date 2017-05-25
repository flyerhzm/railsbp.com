class Users::RegistrationsController < Devise::RegistrationsController
  def edit
    if current_user.fakemail?
      current_user.email = ""
    end
  end

  def update
    if current_user.update_attributes(user_params)
      redirect_to edit_user_registration_path, notice: "Successfully updated user."
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
