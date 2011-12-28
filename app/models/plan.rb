class Plan < ActiveRecord::Base
  has_many :users

  scope :free, where(amount: 0)

  def free?
    amount == 0
  end

  def has_trial?
    trial_period_days > 0
  end
end
