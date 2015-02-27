class TestMailer < ActionMailer::Base
  default from: 'notifications@example.com'
 
  def some_test_email
    headers['X-Mailgun-Campaign-Id'] = "esxli"
    mail(
      to: 'pavlo.shabat@perfectial.com',
      subject: 'Test email'
    )
  end
end