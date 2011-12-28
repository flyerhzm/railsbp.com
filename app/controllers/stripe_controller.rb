class StripeController < ApplicationController
  def handle
    case params["event"]
    when "recurring_payment_failed"
      customer.notify_user_pay_failed
    when "invoice_ready"
      # nothing to do
    when "recurring_payment_succeeded"
      customer.invoices.create(
        total: params["invoice"]["total"],
        period_start: params["invoice"]["period_start"],
        period_end: params["invoice"]["period_end"],
        raw: params
      )
      customer.pay!
    when "subscription_trial_ending"
      # nothing to do
    when "subscription_final_payment_attempt_failed"
      customer.unpay!
    when "ping"
      # nothing to do
    else
      # nothing to do
    end
    render json: {}
  end

  protected
    def customer
      @customer ||= User.where(stripe_customer_token: params["customer"]).first
    end
end
