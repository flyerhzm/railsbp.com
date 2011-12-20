# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do
      plan_id 1
      email "MyString"
      stripe_customer_token "MyString"
    end
end