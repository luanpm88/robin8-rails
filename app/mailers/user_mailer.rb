class UserMailer < ActionMailer::Base

  def payment_confirmation(payment)
    @payment = payment
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

  def newswire_support(myprgenie, accesswire, prnewswire, title, text, newswire_published_at)
    @myprgenie = myprgenie
    @accesswire = accesswire
    @prnewswire = prnewswire
    @newswire_published_at = newswire_published_at
    @title = title
    @text = text
    mail(:to => 'daniel.niiaziiev@perfectial.com', :subject => "New newswire release",:from => "Robin8 <no-reply@robin8.com>")
  end

end
