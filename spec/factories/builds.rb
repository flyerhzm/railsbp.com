# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
      warning_count 0
      association(:repository)
      state "scheduled"
    end
end
