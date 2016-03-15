module Influence
  class Other

    #kol 手机型号等级
    MobileModelLevels = [{:model => 'iphone6', :score => 30},
                        {:model => 'iphone5', :score => 25},
                        {:model => 'iphone4', :score => 20},
                        {:model => 'huawei', :score => 25},
                        {:model => 'mi', :score => 15},
                        {:model => 'samsung', :score => 25},
                        {:model => 'honor', :score => 15},
                        {:model => 'letv', :score => 10},
                        {:model => 'meizu', :score => 10},
                        {:model => 'oppo', :score => 10},
                        {:model => '', :score => 0}]
    def self.mobile_model_score(device_model)
      device_model = device_model.gsub(" ","").downcase
      MobileModelLevels.each do |level|
        return level[:score] if  level[:model].include?(device_model)
      end
    end

    #kol 归属地
    KolLocationScore = [30,20,15,10,0]
    def self.kol_location_score(city_name)
      city_name = city_name[0,2]
      if Util::FirstCitys.include? city_name
        return KolLocationScore[0]
      elsif Util::SecondCitys.include? city_name
        return KolLocationScore[1]
      elsif Util::ThirdCitys.include? city_name
        return KolLocationScore[2]
      elsif Util::FourthCitys.include? city_name
        return KolLocationScore[3]
      else
        return KolLocationScore[4]
      end
    end

    # def self.
  end
end
