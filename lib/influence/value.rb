module Influence
  class Value
    #https://robin8.atlassian.net/wiki/display/RPM/KOL+Influence+Scoring+Algorithm
    #获取用户城市
    def self.get_kol_city(kol_uuid)
      kol_city = ''
      TmpIdentity.where(:kol_uuid => kol_uuid).each do |identity|
        if identity.provider == 'weibo'
          city_names = JSON.parse(identity.serial_params)['location'].split(" ") rescue []
          kol_city = City.where("name like '%#{city_names[0]}%' or name like '%#{city_names[1]}%'").first.name     rescue nil
        else
          city_en_name = JSON.parse(identity.serial_params)['city'].downcase    rescue nil
          kol_city = City.where("name_en like '%#{city_en_name}%'").first.name     rescue nil
        end
        break if kol_city.present?
      end
      return kol_city
    end

    InfluenceLevels = [{:title => "影响力极好", :score => 800},
                       {:title => "影响力优秀", :score => 700},
                       {:title => "影响力尚可", :score => 550},
                       {:title => "影响力极具潜力", :score => 350}]
    def self.get_influence_level(score)
      InfluenceLevels.each do |level|
        return level[:title]  if score >= level[:score]
      end
    end

  end
end
