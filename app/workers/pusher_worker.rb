class PusherWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :campaign, :retry => 3
  sidekiq_retry_in do |count|
    10 * (count + 1)
  end

  def perform(pusher_message_id)
    Getui.send(pusher_message_id)
  end

end
