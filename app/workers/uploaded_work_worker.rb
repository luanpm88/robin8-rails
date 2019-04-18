class UploadedWorkWorker
  include Sidekiq::Worker


  def perform(email, url)
    UserMailer.uploaded_work(email, url).deliver_now
  end

end