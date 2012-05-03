# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
    sequence(:github_name) { |n| "user/repo#{n}" }
    sequence(:html_url) { |n| "https://github.com/user/repo#{n}" }
    sequence(:git_url) { |n| "git://github.com/user/repo#{n}.git" }
    sequence(:name) { |n| "repo#{n}" }
    description "repository"
    private false
    fork false
    pushed_at "2011-11-23 22:48:10"
    sequence(:github_id) { |n| n }
  end
end
