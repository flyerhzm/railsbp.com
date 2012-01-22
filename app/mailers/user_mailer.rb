class UserMailer < ActionMailer::Base
  default from: "<Railsbp.com> notification@railsbp.com"

  def notify_payment_success(invoice_id)
    @invoice = Invoice.find(invoice_id)
    @user = @invoice.user

    mail(:to => @user.email,
         :subject => "[Railsbp] Payment Receipt")
  end

  def notify_payment_final_failed(user_id)
    @user = User.find(user_id)

    mail(:to => @user.email,
         :subject => "[Railsbp] Payment Failed")
  end

  def notify_payment_failed(user_id)
    @user = Invoice.find(user_id)

    mail(:to => @user.email,
         :subject => "[Railsbp] Payment Failed")
  end

  def notify_build_success(build_id)
    @build = Build.find(build_id)
    @repository = @build.repository

    mail(:to => @build.recipient_emails,
         :subject => "[Railsbp] #{@repository.github_name} build ##{@build.position}, warnings count #{@build.warning_count}")
  end
end
