class ExceptionMailer < ActionMailer::Base

  def deliver_notification(title, content, options = {})
    mail(options.reverse_merge({
      subject: title,
      body: content
    })).deliver
  end
end
