# == Schema Information
#
# Table name: configurations
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :string(255)
#  url         :string(255)
#  category_id :integer(4)
#

class Configuration < ActiveRecord::Base
  has_many :parameters
  belongs_to :category

  after_save :notify_collaborators

  protected

  def notify_collaborators
    NotifyCollaboratorsJob.perform_later(id)
  end
end
