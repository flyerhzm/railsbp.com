# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
      url "MyString"
      git_url "MyString"
      name "MyString"
      description "MyString"
      private false
      fork false
      master_branch "MyString"
      pushed_at "2011-11-23 22:48:10"
    end
end