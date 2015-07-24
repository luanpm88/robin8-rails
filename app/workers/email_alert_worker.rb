class EmailAlertWorker
  include Sidekiq::Worker

  def perform(alert_id) 
    AlertMailer.recent_stories(alert_id).deliver_now
  end
end
