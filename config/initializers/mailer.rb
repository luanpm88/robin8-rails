ActionMailer::Base.smtp_settings = {
  :port           => Rails.application.secrets.smtp[:port],
  :address        => Rails.application.secrets.smtp[:address],
  :user_name      => Rails.application.secrets.smtp[:user_name],
  :password       => Rails.application.secrets.smtp[:password],
  :domain         => Rails.application.secrets.smtp[:domain],
  :authentication => :plain,
}
ActionMailer::Base.delivery_method = Rails.application.secrets.smtp[:method]
