require 'rest-client'
class PhoneLocation
  JuheService = "http://apis.juhe.cn/mobile/get"
  JuheKey = Rails.application.secrets.juhe_key

  #https://www.juhe.cn/docs/api/id/11

  def self.get_location(phone,list)
    respond_json = RestClient.get JuheService, {:params => {:key => JuheKey, :phone => phone}, :timeout => 1 }       rescue ""
    respond = JSON.parse respond_json
    if  respond["resultcode"] == "200"
      city = respond["result"]["city"]
      list << city
      Rails.logger.sidekiq.info city
      # Rails.logger.sidekiq.info city
      # values << city
    end
  end

  FirstCitys = "北京、上海、广州、深圳".split("、")
  SecondCitys = "重庆、天津、沈阳、南京、武汉、成都、大连、杭州、青岛、济南、厦门、福州、西安、长沙".split("、")
  ThirdCitys = "哈尔滨、长春、大庆、宁波、苏州、无锡、合肥、郑州、佛山、南昌、贵阳、南宁、石家庄、太原、温州、烟台、珠海、常州、南通、扬州、
                徐州、东莞、威海、淮安、呼和浩特、镇江、潍坊、中山、临沂、咸阳、包头、嘉兴、惠州、泉州、秦皇岛、洛阳".split("、")
  FourthCitys = "乌鲁木齐、海口、兰州、西宁、银川、齐齐哈尔、鞍山、昆山、三亚、廊坊、芜湖、抚顺、德阳、鄂尔多斯、金华、营口、唐山、保定、
                邢台、桂林、吉林、九江、锦州、安庆、邯郸、赣州、泰安、柳州、榆林、新乡、舟山、南阳、聊城、东营、淄博、漳州、沧州、丹东、
                宜兴、绍兴、湖州、衡阳、郴州、泰州、普宁、汕头、揭阳、襄阳、宜昌、大同、湘潭、盐城、马鞍山、介休、长治、日照、常熟、肇庆、
                滨州、台州、株洲、绵阳、平顶山、龙岩、晋江、昆明、连云港、张家港、岳阳、济宁、江门、运城".split("、")
  def self.get_city_value(city)
     if FirstCitys.include? city
       return 1
     elsif SecondCitys.include? city
       return 0.8
     elsif ThirdCitys.include? city
       return 0.7
     elsif FourthCitys.include? city
       return 0.6
     else
       return 0.5
     end
  end

  def self.test
    mobiles  = Kol.where("mobile_number is not null").limit(200).collect{|t| t.mobile_number}
    get_locations(mobiles)
  end
end
