class CreditCard < ActiveRecord::Base
  belongs_to :user

  def expire_date
    sprintf("%02d/%4d", exp_month, exp_year)
  end
end
