class Invoice < ActiveRecord::Base
  belongs_to :user

  after_create :deliver_email

  protected
    def deliver_email
      UserMailer.delay.notify_payment_success(self.id)
    end
end
