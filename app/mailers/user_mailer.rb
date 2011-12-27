class UserMailer < ActionMailer::Base
  default from: "<Railsbp.com> notification@railsbp.com"

  def notify_payment_success(invoice_id)
    @invoice = Invoice.find(invoice_id)
    @user = @invoice.user

    mail(:to => @user.email,
         :subject => "[Railsbp] Payment Receipt")
  end
end
