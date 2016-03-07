class PusherWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :campaign, :retry => 3
  sidekiq_retry_in do |count|
    10 * (count + 1)
  end

  def perform(push_message_id)
    GeTui::Dispatcher.send_message(push_message_id)
  end

end
