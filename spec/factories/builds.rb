# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :build do
    warning_count 0
    last_commit_id "1234567890"
    last_commit_message "test"
    branch "master"
    association(:repository)
  end
end
