class DeliverTestPitchWorker
  include Sidekiq::Worker

  def perform(test_email_id)
    test_email = TestEmail.find(test_email_id)
    
    ContactMailer.deliver_test_pitch(test_email_id).deliver
  end
end
