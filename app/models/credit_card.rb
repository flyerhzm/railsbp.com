# == Schema Information
#
# Table name: credit_cards
#
#  id         :integer(4)      not null, primary key
#  last4      :string(255)
#  card_type  :string(255)
#  exp_month  :integer(4)
#  exp_year   :integer(4)
#  user_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class CreditCard < ActiveRecord::Base
  belongs_to :user

  def expire_date
    sprintf("%02d/%4d", exp_month, exp_year)
  end
end
