# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan do
    name "Basic"
    amount "9.99"
    interval "month"
  end

  factory :free_plan, parent: :plan do
    name "Free"
    amount "0.00"
    interval "month"
  end
end
