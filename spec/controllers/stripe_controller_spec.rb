require 'spec_helper'

describe StripeController do
  context "#handle" do
    before do
      @user = Factory(:user, stripe_customer_token: "cus_RTW3KxBMCknuhB")
    end

    context "recurring_payment_failed" do
      it "should notify user" do
        User.any_instance.expects(:notify_user_pay_failed)
        post :handle, recurring_payment_failed_request
      end
    end

    context "invoice_ready" do
      it "should do nothing" do
        post :handle, ping_request
        response.should be_ok
      end
    end

    context "recurring_payment_succeeded" do
      it "should create an invoice" do
        lambda {
          post :handle, recurring_payment_succeeded_request
        }.should change(@user.invoices, :count).by(1)

        @user.reload
        response.should be_ok
        @user.aasm_state.should == "paid"
      end
    end

    context "subscription_trial_ending" do
      it "should do nothing" do
        post :handle, ping_request
        response.should be_ok
      end
    end

    context "subscription_final_payment_attempt_failed" do
      it "should downgrade user to free plan" do
        free_plan = Factory(:plan, amount: 0, name: "Free")
        basic_plan = Factory(:plan, amount: 500, name: "Basic")
        Factory(:invoice, user: @user)
        @user.pay!
        @user.update_attributes(plan: basic_plan)
        post :handle, subscription_final_payment_attempt_failed_request

        @user.reload
        response.should be_ok
        @user.aasm_state.should == "unpaid"
      end
    end

    context "ping" do
      it "should do nothing" do
        post :handle, ping_request
        response.should be_ok
      end
    end

    def recurring_payment_failed_request
      ActiveSupport::JSON.decode(body = <<-EOF
        {
          "customer":"cus_RTW3KxBMCknuhB",
          "livemode": true,
          "event": "recurring_payment_failed",
          "attempt": 2,
          "invoice": {
            "attempted": true,
            "charge": "ch_sUmNHkMiag",
            "closed": false,
            "customer": "cus_RTW3KxBMCknuhB",
            "date": 1305525584,
            "id": "in_jN6A1g8N76",
            "object": "invoice",
            "paid": true,
            "period_end": 1305525584,
            "period_start": 1305525584,
            "subtotal": 2000,
            "total": 2000,
            "lines": {
              "subscriptions": [
                {
                  "period": {
                    "start": 1305525584,
                    "end": 1308203984
                  },
                  "plan": {
                    "object": "plan",
                    "name": "Premium plan",
                    "id": "premium",
                    "interval": "month",
                    "amount": 2000
                  },
                  "amount": 2000
                }
              ]
            }
          },
          "payment": {
            "time": 1297887533,
            "card": {
              "type": "Visa",
              "last4": "4242"
            },
            "success": false
          }
        }
        EOF
      )
    end

    def invoice_ready
      ActiveSupport::JSON.decode(body =<<-EOF
        {
          "customer":"cus_RTW3KxBMCknuhB",
          "event":"invoice_ready",
          "livemode":true,
          "invoice": {
            "total": 1500,
            "subtotal": 3000,
            "lines": {
              "invoiceitems": [
                {
                  "id": "ii_N17xcRJUtn",
                  "amount": 1000,
                  "date": 1303586118,
                  "currency": "usd",
                  "description": "One-time setup fee"
                }
              ],
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
                    "id": "premium"
                  }
                }
              ]
            },
            "object": "invoice",
            "discount": {
              "coupon": {
                "id": "50OFF",
                "livemode": false,
                "percent_off": 50,
                "object": "coupon"
              },
              "start": 1304588585
            },
            "date": 1304588585,
            "period_start": 1304588585,
            "id": "in_jN6A1g8N76",
            "period_end": 1304588585
          }
        }
        EOF
      )
    end

    def recurring_payment_succeeded_request
      ActiveSupport::JSON.decode(body = <<-EOF
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

    def subscription_trial_ending
      ActiveSupport::JSON.decode(body =<<-EOF
        {
          "customer":"cus_RTW3KxBMCknuhB",
          "event":"subscription_trial_ending",
          "livemode":true,
          "subscription":
          {
            "trial_start": 1304627445,
            "trial_end": 1307305845,
            "plan": {
              "trial_period_days": 31,
              "amount": 2999,
              "interval": "month",
              "id": "silver",
              "name": "Silver"
            }
          }
        }
        EOF
      )
    end

    def subscription_final_payment_attempt_failed_request
      ActiveSupport::JSON.decode(body =<<-EOF
        {
          "customer":"cus_RTW3KxBMCknuhB",
          "event":"subscription_final_payment_attempt_failed",
          "livemode":true,
          "subscription": {
            "status": "canceled",
            "start": 1304585542,
            "plan": {
              "amount": 2000,
              "interval": "month",
              "object": "plan",
              "id": "silver"
            },
            "canceled_at": 1304585552,
            "ended_at": 1304585552,
            "object": "subscription",
            "current_period_end": 1307263942,
            "current_period_start": 1304585542
          }
        }
        EOF
      )
    end

    def ping_request
      ActiveSupport::JSON.decode(body =<<-EOF
        {
          "event": "ping"
        }
        EOF
      )
    end
  end
end
