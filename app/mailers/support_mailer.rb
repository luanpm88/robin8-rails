class SupportMailer < ApplicationMailer

  def payment_failure(params, error)
    @params = params
    @error = error
    env = Rails.env
    mail(:to => 'qa@redwerk.com', :subject => "Robin8 payment fail (#{env})",:from => "Robin8 <no-reply@robin8.me>")
  end
end
