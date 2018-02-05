class NewMemberWorker
  include Sidekiq::Worker


  def perform(email, valid_code)
    UserMailer.new_member(email, valid_code).deliver_now
  end

end
