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
      :token => @token,
      :html => html,
      :resource_type => @resource.model_name.human.downcase
    }

    ConfirmationMailWorker.perform_async data, 'confirmation_instructions'
  end

  def reset_password_instructions record, token, opts={}
    @resource = record
    @token = token
    template = 'kols/mailer/reset_password_instructions'
    html = render(template: template)

    data = {
      :to => @resource.email,
      :token => token,
      :html => html,
      :resource_type => @resource.model_name.human.downcase
    }

    ConfirmationMailWorker.perform_async data, 'reset_password_instructions'
  end
end
