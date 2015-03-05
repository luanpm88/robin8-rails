class UserMailer < ActionMailer::Base

  def successfull_subscription(subscription)
    @subscription = subscription
    mail(:to => @subscription.user.email, :subject => "Successfull Subscription",:from => "Robin8 <no-reply@robin8.com>")
  end
end