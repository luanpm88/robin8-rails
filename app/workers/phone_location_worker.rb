class PhoneLocationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :phone_location, :retry => 1

  def perform(phone, store_key)


  end

end
