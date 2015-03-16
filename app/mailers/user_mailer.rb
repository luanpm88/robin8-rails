class UserMailer < ActionMailer::Base

  def successfull_subscription(subscription)
    @subscription = subscription
    mail(:to => @subscription.user.email, :subject => "Successfull Subscription",:from => "Robin8 <no-reply@robin8.com>")
  end

  def contact_support(user)
    @user = user
    mail(:to => 'info@robin8.com', :subject => "Contact Us Request",:from => "Robin8 <no-reply@robin8.com>")
  end

end