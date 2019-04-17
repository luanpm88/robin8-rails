class UserMailer < ActionMailer::Base

  def payment_confirmation(user, payment)
    @payment = payment
    @user = user
    mail(:to => @payment.user_product.user.email, :subject => "Successfull Payment",:from => "Robin8 <no-reply@robin8.com>")
  end

  def contact_support(user)
    @user = user
    mail(:to => 'support_cn@robin8.com', :subject => "Contact Us Request",:from => "Robin8 <no-reply@robin8.com>")
  end

  def withdraw_apply(withdraw_id)
    @withdraw = Withdraw.find withdraw_id  rescue nil
    @kol = @withdraw.kol  if @withdraw
    mail(:to => 'support_cn@robin8.com', :subject => "Withdraw Apply", :from => "Robin8 <no-reply@robin8.com>")
  end

  def add_ons_payment_confirmation(add_ons,user,add_on_hash,tax_rate,prices)
    @add_ons = add_ons
    @user = user
    @add_on_hash = add_on_hash
    @tax_rate = tax_rate.to_f
    @prices = prices
    mail(:to => @user.email, :subject => "Add Ons Confirmation",:from => "Robin8 <no-reply@robin8.com>")
  end

  def newswire_support(user, release_title, newswire_name, newswire_start_date, link_to_release)
    @user = user
    @release_title = release_title
    @link_to_release = link_to_release
    @selected_newswire = newswire_name
    @newswire_publish_date = newswire_start_date

    mail(:to => Rails.application.secrets.support_emails, :subject => "Robin8 Newswire Notification",:from => "Robin8 <no-reply@robin8.com>")
  end

  def new_member(email, valid_code)
    @email      = email
    @valid_code = valid_code

    mail(to: @email, subject: "Welcome to Robin8", from: "Robin8 <system@robin8.com>")
  end

  def new_quote(email, url)
    @email  = email
    @url    = url

    mail(to: @email, subject: "You have received new quote", from: "Robin8 <system@robin8.com>")
  end

end
