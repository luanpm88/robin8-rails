class ConfirmationMailWorker
  include Sidekiq::Worker

  def perform data
    Rails.logger.sidekiq.info "Started perform #{self.class.to_s} with args: #{data['to']}"
    send_data = {
      :from => 'noreply@robin8.net',
      :fromname => 'Robin8',
      :subject => '注册验证',
      :use_maillist => false
    }.merge data

    sendcloud_client = Sendcloud::Client.new

    begin
      sendcloud_client.send_message(send_data)
    rescue => e
      Rails.logger.sidekiq.error "Perform #{self.class.to_s} failed with args: #{data['to']}, error msg: #{e.message}"
      return
    end

    Rails.logger.sidekiq.info "Completed perform #{self.class.to_s}"
  end
end
