ActionMailer::Base.smtp_settings = {
  :port           => Rails.application.secrets.mailgun[:port],
  :address        => Rails.application.secrets.mailgun[:address],
  :user_name      => Rails.application.secrets.mailgun[:user_name],
  :password       => Rails.application.secrets.mailgun[:password],
  :domain         => Rails.application.secrets.mailgun[:domain],
  :authentication => :plain,
}
ActionMailer::Base.delivery_method = Rails.application.secrets.mailgun[:method]
