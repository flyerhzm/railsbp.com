# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
      total 1
      period_start 1
      period_end 1
      raw "MyText"
    end
end