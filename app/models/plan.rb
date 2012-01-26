# == Schema Information
#
# Table name: plans
#
#  id                       :integer(4)      not null, primary key
#  name                     :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  identifier               :string(255)
#  amount                   :integer(4)      default(0)
#  interval                 :string(255)
#  livemode                 :boolean(1)      default(FALSE)
#  trial_period_days        :integer(4)      default(0)
#  visible                  :boolean(1)      default(FALSE), not null
#  allow_privacy            :boolean(1)      default(FALSE), not null
#  allow_repositories_count :integer(4)      default(0), not null
#

class Plan < ActiveRecord::Base
  has_many :users

  scope :free, where(amount: 0)
  scope :visible, where(visible: true)

  def free?
    amount == 0
  end

  def has_trial?
    trial_period_days > 0
  end
end
