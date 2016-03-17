  class PhoneLocation
    JuheService = "http://apis.juhe.cn/mobile/get"
    JuheKey = Rails.application.secrets.juhe_key

    #https://www.juhe.cn/docs/api/id/11

    def self.get_location(phone, store_key, kol_uuid)
      respond_json = RestClient.get JuheService, {:params => {:key => JuheKey, :phone => phone}, :timeout => 0.8 }       rescue ""
      respond = JSON.parse respond_json
      Rails.logger.sidekiq.error "----respond:#{respond}----"
      if  respond["resultcode"] == "200"
        city = respond["result"]["city"]
        value = get_city_value city
        # mobile_location  = {:value => value, :phone => phone}
        Rails.logger.sidekiq.error "----store_key:#{store_key}----value:#{value}"
        Rails.cache.write(store_key, value, :expires_in => 15.minutes)
      end
    end


    def self.get_city_value(city)
      city = city[0,2]
       if Influence::Util::FirstCitys.include? city
         return 1
       elsif Influence::Util::SecondCitys.include? city
         return 0.8
       elsif Influence::Util::ThirdCitys.include? city
         return 0.7
       elsif Influence::Util::FourthCitys.include? city
         return 0.6
       else
         return 0.5
       end
    end

  end
