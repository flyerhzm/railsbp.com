class StripeController < ApplicationController
  def handle
    case params["event"]
    when "recurring_payment_failed"
      # notify user
    when "invoice_ready"
      # nothing to do
    when "recurring_payment_succeeded"
      # notify user
      user = User.where(stripe_customer_token: params["customer"]).first
      user.invoices.create(
        total: params["invoice"]["total"],
        period_start: params["invoice"]["period_start"],
        period_end: params["invoice"]["period_end"],
        raw: params
      )
      render json: {}
    when "subscription_trial_ending"
      # notify user
    when "subscription_final_payment_attempt_failed"
      # notify user and downgrade to free plan
    when "ping"
      render json: {}
    else
      # nothing to do
    end
  end
end
