require 'rest-client'
class PhoneLocation
  JuheService = "http://apis.juhe.cn/mobile/get"
  JuheKey = Rails.application.secrets.juhe_key

  #https://www.juhe.cn/docs/api/id/11

  $values = []
  def self.get_location(phone,store_key)
    respond_json = RestClient.get JuheService, {:params => {:key => JuheKey, :phone => phone}, :timeout => 1 }       rescue ""
    respond = JSON.parse respond_json
    if  respond["resultcode"] == "200"
      city = respond["result"]["city"]
      $values << city
      Rails.logger.sidekiq.info city
      # Rails.logger.sidekiq.info city
      # values = Rails.cache.read(store_key)
      # values << city
      # Rails.logger.sidekiq.info values
      # Rails.cache.write(store_key,values)
    end
  end


  def self.get_locations(mobiles)
    store_key = SecureRandom.uuid
    Rails.cache.write(store_key,[])
    mobile_size = 0
    mobiles.each do |mobile|
      puts "------#{mobile}"
      if is_mobile?(mobile)
        mobile_size += 1
        PhoneLocationWorker.perform_async(mobile,store_key)
      end
    end
    loop_times = 0
    loop_seconds = 0.2
    while  true
       break if loop_times >= 50 ||  Rails.cache.read(store_key).size >= mobile_size * 0.9
       loop_times += 1
       sleep loop_seconds
    end
    puts mobile_size
    puts $values
  end

  #是否mobile
  def self.is_mobile?(mobile)
    mobile =~ /^((13[0-9])|(15[^4,\D])|(18[0-9])|(14[5,7])|(17[0-9]))\d{8}$/
  end

  def self.test
    mobiles  = Kol.where("mobile_number is not null").limit(200).collect{|t| t.mobile_number}
    get_locations(mobiles)
  end
end
