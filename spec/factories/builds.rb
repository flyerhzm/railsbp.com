# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
      warning_count 1
      repository_id 1
      state "MyString"
    end
end