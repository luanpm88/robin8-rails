module Influence
  class Contact
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
      cal_mobile_scores = get_mobile_scores(kol_uuid, cal_mobiles)
      Rails.logger.info "===============cal_score---#{Time.now}"
      # 获取所有好友加权后好友人数 需还原 加权人数
      contact_count = cal_mobile_scores.sum *  (mobile_size /  cal_mobile_scores.size.to_f)
      hunder_score = ContactLevels.each do |level|
        return level[:score] if contact_count > level[:min_count]
      end
      Rails.logger.info "===============cal_score---hunder_score:#{hunder_score}"
      Rails.cache.write(Value.contact_key(kol_uuid), hunder_score, :expires_in => 1.days)
    end

    def self.get_mobile_scores(kol_uuid, cal_mobiles)
      cal_mobiles_size = cal_mobiles.size
      store_keys = []
      cal_mobiles.each_with_index do |mobile, index|
        store_key = "#{kol_uuid}#{index}"
        if is_mobile?(mobile)
          store_keys << store_key
          PhoneLocationWorker.perform_async(mobile , store_key, kol_uuid)
        else
          Rails.cache.write(store_keys, 0.5)
        end
      end
      Rails.logger.info  store_keys
      loop_times = 0
      loop_seconds = 0.1
      scores_hash = {}
      while  true
        eval("scores_hash = Rails.cache.fetch_multi(#{store_keys.join(",")}){nil}")
        break if loop_times >= 50 ||  scores_hash.values.compact.size >= cal_mobiles_size * 0.8
        loop_times += 1
        sleep loop_seconds
      end
      Rails.logger.info  scores_hash.values
      return scores_hash.values.compact
    end


    #是否mobile
    def self.is_mobile?(mobile)
      mobile =~ /^((13[0-9])|(15[^4,\D])|(18[0-9])|(14[5,7])|(17[0-9]))\d{8}$/
    end



    def self.test
      kol_uuid = Time.now.to_i
      puts kol_uuid
      mobiles  = Kol.where("mobile_number is not null").limit(200).collect{|t| t.mobile_number}
      Rails.logger.info "===============test---#{Time.now}"
      cal_score(kol_uuid, mobiles)
    end
  end
end
