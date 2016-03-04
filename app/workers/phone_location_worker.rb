class PhoneLocationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :phone_location, :retry => 0

  def perform(phone, contact_scores, mobile_location)
    Influence::PhoneLocation.get_location(phone,contact_scores, mobile_location)
  end

end
