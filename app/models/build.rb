class Build < ActiveRecord::Base
  include AASM

  belongs_to :repository

  aasm do
    state :scheduled, :initial => true
    state :running
    state :completed

    event :run do
      transitions :to => :running, :from => :scheduled
    end

    event :complete do
      transitions :to => :completed, :from => :running
    end
  end
end
