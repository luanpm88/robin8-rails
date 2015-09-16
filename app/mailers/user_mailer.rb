class UserMailer < ActionMailer::Base

  def payment_confirmation(user, payment)
    @payment = payment
    @user = user
    mail(:to => @payment.user_product.user.email, :subject => "Successfull Payment",:from => "Robin8 <no-reply@robin8.com>")
  end

  def contact_support(user)
    @user = user
    mail(:to => 'info@robin8.com', :subject => "Contact Us Request",:from => "Robin8 <no-reply@robin8.com>")
  end

  def add_ons_payment_confirmation(add_ons,user,add_on_hash)
    @add_ons = add_ons
    @user = user
    @add_on_hash = add_on_hash
    mail(:to => @user.email, :subject => "Add Ons Confirmation",:from => "Robin8 <no-reply@robin8.com>")
  end

  def newswire_support(user, release_title, newswire_types, publish_date, link_to_release)
    @user = user
    @release_title = release_title
    @newswire_types = newswire_types.join(', ')
    @newswire_publish_date = publish_date
    @link_to_release = link_to_release
    mail(:to => Rails.application.secrets.support_emails, :subject => "Robin8 Newswire Notification",:from => "Robin8 <no-reply@robin8.com>")
  end

end
