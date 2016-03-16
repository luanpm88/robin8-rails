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
        return level[:score] if  device_model.include?(level[:model])
      end
    end

    #kol 归属地 得分
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

    # 社交账号数量得分
    IdentityCountLevels= [{:count => 3, :score => 50},
                          {:count => 2, :score => 30},
                          {:count => 1, :score => 10},
                          {:model => 0, :score => 0}]
    def self.identity_count_score(kol_uuid)
      count = TmpIdentity.where(:kol_uuid => kol_uuid).count
      IdentityCountLevels.each do |level|
        return level[:score] if  count >= level[:count]
      end

    end
  end
end
