# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :credit_card do
      last4 "MyString"
      card_type "MyString"
      exp_month 1
      exp_year 1
    end
end