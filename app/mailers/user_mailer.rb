class UserMailer < ActionMailer::Base

  def successfull_subscription(user_product)
    @user_product = user_product
    mail(:to => @user_product.user.email, :subject => "Successfull Payment",:from => "Robin8 <no-reply@robin8.com>")
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

end