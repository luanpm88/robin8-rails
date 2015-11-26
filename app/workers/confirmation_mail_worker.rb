class ConfirmationMailWorker
  include Sidekiq::Worker

  def perform data, mail_type
    Rails.logger.sidekiq.info "Started perform #{self.class.to_s} with args: #{data['to']}, #{mail_type}"

    if Rails.application.config.china_instance
      # use sendcloud for china instance
      resource_type = data['resource_type'] + 's'

      if mail_type.eql? 'confirmation_instructions'
        vars = JSON.dump({"to" => [data['to']], "sub" => {"%email%" => [data['to']], "%url%" => ["http://#{Rails.application.secrets.host}/#{resource_type}/confirmation?confirmation_token=#{data['token']}"]}})
        template = 'test_template_active'
      else
        vars = JSON.dump({"to" => [data['to']], "sub" => {"%email%" => [data['to']], "%url%" => ["http://#{Rails.application.secrets.host}/#{resource_type}/confirmation?confirmation_token=#{data['token']}"]}})
        template = 'reset_password'
      end

      send_data = {
        :from => Rails.application.secrets.sendcloud[:from_address],
        :fromname => Rails.application.secrets.sendcloud[:from_name],
        :subject => I18n.t('devise.mailer.' + mail_type + '.subject'),
        :use_maillist => false,
        :template_invoke_name => template,
        :substitution_vars => vars
      }

      sendcloud_client = Sendcloud::Client.new
      begin
        sendcloud_client.send(send_data, type=:template)
      rescue => e
        Rails.logger.sidekiq.error "Perform #{self.class.to_s} failed with args: #{data['to']} & #{mail_type}, error msg: #{e.message}"
        return
      end
    else
      # use mailgun for us instance
      send_data = {
        :from => Rails.application.secrets.mailgun[:from],
        :subject => I18n.t('devise.mailer.confirmation_instructions.subject')
      }.merge(data.tap { |d| d.delete(:token) })

      mg_client = Mailgun::Client.new(Rails.application.secrets.mailgun[:api_key], api_host='api.mailgun.net', api_version='v3')
      send_domain = Rails.application.secrets.mailgun[:send_domain]
      begin
        result = mg_client.send_message(send_domain, send_data)
      rescue => e
        Rails.logger.sidekiq.error "Perform #{self.class.to_s} failed with args: #{data['to']}, error msg: #{e.message}"
        return
      end
    end

    Rails.logger.sidekiq.info "Completed perform #{self.class.to_s}"
  end
end
