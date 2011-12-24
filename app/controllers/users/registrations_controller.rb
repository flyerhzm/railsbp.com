class Users::RegistrationsController < Devise::RegistrationsController
  def edit
  end

  def update_credit_card
    if current_user.save_stripe_customer(params[:user])
      redirect_to [:plans], :notice => "Thank you for updating credit card"
    else
      redirect_to [:plans], :error => current_user.errors.full_messages
    end
  end

  def update_plan
    if current_user.update_plan(params[:plan_id])
      redirect_to [:plans], :notice => "Thank you for updating plan"
    else
      redirect_to [:plans], :error => current_user.errors.full_messages
    end
  end
end
