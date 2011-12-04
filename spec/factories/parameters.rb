# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :parameter do
      name "MyString"
      kind "MyString"
      configuration_id 1
    end
end