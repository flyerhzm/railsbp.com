class Plan < ActiveRecord::Base
  has_many :users

  scope :free, where(amount: 0)
end
