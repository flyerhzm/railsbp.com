class Configuration < ActiveRecord::Base
  has_many :parameters
  belongs_to :category
end
