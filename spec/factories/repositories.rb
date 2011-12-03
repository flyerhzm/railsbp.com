# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repository do
      sequence(:html_url) { |n| "http://test.com/repo#{n}" }
      sequence(:git_url) { |n| "http://test.com/repo#{n}.git" }
      sequence(:name) { |n| "repo#{n}" }
      description "repository"
      private false
      fork false
      master_branch "master"
      pushed_at "2011-11-23 22:48:10"
      sequence(:github_id) { |n| n }
    end
end
