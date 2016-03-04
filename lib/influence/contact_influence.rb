$value = []

module Influence
  class ContactInfluence
    #计算 加权好友数后 得分
    ContactLevels = [{:min_count => 500, :score => 100},
                     {:min_count => 400, :score => 90},
                     {:min_count => 300, :score => 80},
                     {:min_count => 200, :score => 70},
                     {:min_count => 100, :score => 60},
                     {:min_count => 80, :score => 50},
                     {:min_count => 60, :score => 40},
                     {:min_count => 50, :score => 30},
                     {:min_count => 30, :score => 20},
                     {:min_count => 20, :score => 10},
                     {:min_count => -1, :score => 0}]
    def self.cal_score(kol_uuid,mobiles)
      mobile_size = mobiles.size
      if mobile_size > 100
        cal_mobiles = mobiles.sample(100)
      else
        cal_mobiles = mobiles
      end
      # 获取 cal_mobile（部分好友） 加权人数
      cal_mobile_scores = get_mobile_scores(cal_mobiles)
      # 获取所有好友加权后好友人数 需还原 加权人数
      contact_count = cal_mobile_scores.sum *  (mobile_size /  cal_mobile_scores.size.to_f)
      hunder_score = ContactLevels.each do |level|
        return level[:score] if contact_count > level[:min_count]
      end
      Rails.cache.write(Value.contact_key(kol_uuid),hunder_score)
    end

    def self.get_mobile_scores(cal_mobiles)
      cal_mobiles_size = cal_mobiles.size
      mobile_scores = []
      mobile_location = []
      cal_mobiles.each do |mobile|
        if is_mobile?(mobile)
          PhoneLocationWorker.perform_async(mobile,mobile_scores, mobile_location)
        else
          mobile_scores << 0.5
        end
      end
      loop_times = 0
      loop_seconds = 0.1
      while  true
        break if loop_times >= 50 ||  mobile_scores.size >= cal_mobiles_size * 0.9
        loop_times += 1
        sleep loop_seconds
      end
      return mobile_scores
    end


    #是否mobile
    def self.is_mobile?(mobile)
      mobile =~ /^((13[0-9])|(15[^4,\D])|(18[0-9])|(14[5,7])|(17[0-9]))\d{8}$/
    end



    def self.test
      kol_uuid = Time.now.to_i
      puts kol_uuid
      mobiles  = Kol.where("mobile_number is not null").limit(200).collect{|t| t.mobile_number}
      cal_score(kol_uuid, mobiles)
      puts Rails.cache.read(Value.contact_key(kol_uuid))
    end
  end
end
