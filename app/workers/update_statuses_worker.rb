class UpdateStatusesWorker
  include Sidekiq::Worker

  def perform()
    Identity.where(:provider => 'weibo').each do |identity|
      Weibo.update_statuses(identity)
    end
  end
end
