class ContactMailer < ActionMailer::Base
  default from: "notification@railsbp.com"

  def contact_us(contact)
    @message = contact.message

    mail :from    => contact.email,
         :subject => "Contact Us message from #{contact.name} (#{contact.email})",
         :to      => "contact-us@railsbp.com"
  end
end
