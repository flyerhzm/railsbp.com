# == Schema Information
#
# Table name: invoices
#
#  id           :integer(4)      not null, primary key
#  total        :integer(4)
#  period_start :integer(4)
#  period_end   :integer(4)
#  user_id      :integer(4)
#  raw          :text
#  created_at   :datetime
#  updated_at   :datetime
#

class Invoice < ActiveRecord::Base
  belongs_to :user
end
