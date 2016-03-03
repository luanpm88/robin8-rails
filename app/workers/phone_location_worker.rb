class PhoneLocationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :phone_location, :retry => 0

  def perform(phone, store_key)
    PhoneLocation.get_location(phone,store_key)
  end

end
