class ConfirmationMailWorker
  include Sidekiq::Worker

  def perform data
    Rails.logger.sidekiq.info "Started perform #{self.class.to_s} with args: #{data['to']}"

    if Rails.application.config.china_instance
      # use sendcloud for china instance
      vars = JSON.dump({"to" => [data['to']], "sub" => {"%email%" => [data['to']], "%url%" => ["http://#{Rails.application.secrets.host}/kols/confirmation?confirmation_token=#{data['token']}"]}})
      send_data = {
        :from => Rails.application.secrets.sendcloud[:from_address],
        :fromname => Rails.application.secrets.sendcloud[:form_name],
        :subject => I18n.t('devise.mailer.confirmation_instructions.subject'),
        :use_maillist => false,
        :template_invoke_name => 'test_template_active',
        :substitution_vars => vars
      }

      sendcloud_client = Sendcloud::Client.new
      begin
        sendcloud_client.send(send_data, type=:template)
      rescue => e
        Rails.logger.sidekiq.error "Perform #{self.class.to_s} failed with args: #{data['to']}, error msg: #{e.message}"
        return
      end
    else
      # use mailgun for us instance
      send_data = {
        :from => Rails.application.secrets.mailgun[:from],
        :subject => I18n.t('devise.mailer.confirmation_instructions.subject')
      }.merge(data.tap { |d| d.delete(:token) })

      mg_client = Mailgun::Client.new(Rails.application.secrets.mailgun[:api_key], api_host='api.mailgun.net', api_version='v3')
      begin
        result = mg_client.send_message('mg.wall2flower.moe', send_data)
      rescue => e
        Rails.logger.sidekiq.error "Perform #{self.class.to_s} failed with args: #{data['to']}, error msg: #{e.message}"
        return
      end
    end

    Rails.logger.sidekiq.info "Completed perform #{self.class.to_s}"
  end
end
