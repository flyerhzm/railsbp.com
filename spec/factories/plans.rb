# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :plan do
      name "MyString"
      amount "9.99"
      interval "month"
    end
end
