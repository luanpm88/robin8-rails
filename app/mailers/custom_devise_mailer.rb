class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'kols/mailer'

  def confirmation_instructions record, token, opts={}
    @email = record.email
    @resource = record
    @token = token
    template = 'kols/mailer/confirmation_instructions'
    html = render(template: template)

    data = {
      :to => @resource.email,
      :html => html
    }
    ConfirmationMailWorker.perform_async data
  end

  def reset_password_instructions record, token, opts={}

  end
end
