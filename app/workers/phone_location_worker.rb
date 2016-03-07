class PhoneLocationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :phone_location, :retry => 0

  def perform(phone, store_key, kol_uuid)
    Influence::PhoneLocation.get_location(phone, store_key, kol_uuid)
  end

end
