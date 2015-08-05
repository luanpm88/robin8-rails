# Preview all emails at http://localhost:3000/rails/mailers/support_mailer
class SupportMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/support_mailer/payment_failure
  def payment_failure
    SupportMailer.payment_failure
  end

end
