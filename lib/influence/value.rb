module Influence
  class Value
    #https://robin8.atlassian.net/wiki/display/RPM/KOL+Influence+Scoring+Algorithm
    #计算总价值
    BaseScore = 500
    def self.cal_total_score(kol_uuid, kol_city, kol_mobile_model)
      kol_city = get_kol_city(kol_uuid)   if kol_city.blank?
      location_score = Other.kol_location_score(kol_city)
      mobile_score = Other.mobile_model_score(kol_mobile_model)
      identity_score = Influence::Identity.get_identity_score(kol_uuid)
      identity_count_score = Other.identity_count_score(kol_uuid)
      contact_score = get_contact_score(kol_uuid)
      total_score = BaseScore + location_score + mobile_score + identity_count_score +  contact_score +  identity_score
      Rails.cache.write("total_score_#{kol_uuid}", total_score)
      Rails.cache.write("cal_time_#{kol_uuid}", Time.now)
      total_score
    end

    def self.get_total_score(kol_uuid)
      Rails.cache.read("total_score_#{kol_uuid}")
    end

    def self.get_cal_time(kol_uuid)
      Rails.cache.read("cal_time_#{kol_uuid}")
    end

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


    #联系人得分 等待后台计算
    LoopTimes = 50
    LoopSecond = 0.1
    def self.get_contact_score(kol_uuid)
      return 0 if  Influence::Contact.contact_score(kol_uuid).blank?
      loop_times = 0
      ok = false
      while loop_times < LoopTimes && !ok
        ok = true if   Influence::Contact.contact_score(kol_uuid) != -1
        sleep LoopSecond
        loop_times += 1
      end
      score = Influence::Contact.contact_score(kol_uuid)
      if !score
        contract_count = TmpKolContact.where(:kol_uuid => kol_uuid).count * 0.65
        score = Influence::Contact.cal_score(kol_uuid, nil, contract_count)
      end
      return score
    end

    InfluenceLevels = [{:title => "影响力极好", :score => 800},
                       {:title => "影响力优秀", :score => 700},
                       {:title => "影响力尚可", :score => 550},
                       {:title => "影响力极具潜力", :score => 500}]
    def self.get_influence_level(score)
      InfluenceLevels.each do |level|
        return level[:title]  if score >= level[:score]
      end
    end

  end
end
