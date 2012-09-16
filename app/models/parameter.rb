# == Schema Information
#
# Table name: parameters
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  kind             :string(255)
#  value            :string(255)
#  description      :string(255)
#  configuration_id :integer(4)
#

class Parameter < ActiveRecord::Base
  belongs_to :configuration
  attr_accessible :name, :kind, :value, :description
end
