require 'spec_helper'

describe StripeController do
  context "#handle" do
    context "recurring_payment_succeeded" do
      it "should notify user" do
        user = Factory(:user, stripe_customer_token: "cus_RTW3KxBMCknuhB")
        lambda {
          post :handle, recurring_payment_succeeded_request
        }.should change(user.invoices, :count).by(1)
        response.should be_ok
      end
    end

    def recurring_payment_succeeded_request
      ActiveSupport::JSON.decode(request = <<-EOF
      {
        "customer":"cus_RTW3KxBMCknuhB",
        "livemode": true,
        "event":"recurring_payment_succeeded",
        "invoice": {
          "total": 2000,
          "subtotal": 2000,
          "charge": "ch_sUmNHkMiag",
          "lines": {
            "subscriptions": [
            {
              "amount": 2000,
              "period": {
                "start": 1304588585,
                "end": 1307266985
              },
              "plan": {
                "amount": 2000,
                "interval": "month",
                "object": "plan",
                "id": "premium",
                "name": "Premium plan"
              }
            }
            ]
          },
          "object": "invoice",
          "date": 1304588585,
          "period_start": 1304588585,
          "id": "in_jN6A1g8N76",
          "period_end": 1304588585
        },
        "payment": {
          "time": 1297887533,
          "card":
          {
            "type": "Visa",
            "last4": "4242"
          },
          "success": true
        }
      }
      EOF
      )
    end
  end
end
