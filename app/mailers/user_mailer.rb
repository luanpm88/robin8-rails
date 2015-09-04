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

  def add_ons_payment_confirmation(add_ons,user,add_on_hash,tax_rate,prices)
    @add_ons = add_ons
    @user = user
    @add_on_hash = add_on_hash
    @tax_rate = tax_rate.to_f
    @prices = prices
    mail(:to => @user.email, :subject => "Add Ons Confirmation",:from => "Robin8 <no-reply@robin8.com>")
  end

  def newswire_support(myprgenie, accesswire, prnewswire, title, text, myprgenie_published_at, accesswire_published_at, prnewswire_published_at, publicLink)
    @myprgenie = myprgenie
    @accesswire = accesswire
    @prnewswire = prnewswire
    @myprgenie_published_at = myprgenie_published_at
    @accesswire_published_at = accesswire_published_at
    @prnewswire_published_at = prnewswire_published_at
    @title = title
    @text = text
    @publicLink = publicLink
    mail(:to => Rails.application.secrets.support_email, :subject => "New newswire release",:from => "Robin8 <no-reply@robin8.com>")
  end

end
