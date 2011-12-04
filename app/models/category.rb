class Category < ActiveRecord::Base
  has_many :configurations
end
