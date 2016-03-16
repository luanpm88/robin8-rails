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
    def self.cal_score(kol_uuid, mobiles, contact_count = nil)
      puts mobiles
      contact_count =  contact_count || cal_contact_count(kol_uuid, mobiles)   || 0
      total_score = ContactLevels.each do |level|
        return level[:score] if contact_count > level[:min_count]
      end
      Rails.logger.info "===============Contact:cal_score---total_score:#{total_score}"
      Rails.cache.write(contact_key(kol_uuid), total_score, :expires_in => 1.days)
    end

    # 计算加权人数
    def self.cal_contact_count(kol_uuid,cal_mobiles)
      mobile_size = cal_mobiles.size
      cal_mobiles = cal_mobiles.sample(100)  if mobile_size > 100
      # 获取 cal_mobile（部分好友） 实际加权人数
      cal_mobile_scores = get_mobile_scores(kol_uuid, cal_mobiles)
      Rails.logger.info "===============Contact:cal_score---#{Time.now}"
      # 获取所有好友加权后好友人数 需还原 加权人数
      cal_mobile_scores.sum *  (mobile_size /  cal_mobile_scores.size.to_f)
    end

     #获取样本得分
    def self.get_mobile_scores(kol_uuid, cal_mobiles)
      cal_mobiles_size = cal_mobiles.size
      store_keys = []
      cal_mobiles.each_with_index do |mobile, index|
        store_key = "#{kol_uuid}#{index}"
        if Util.is_mobile?(mobile)
          store_keys << store_key
          PhoneLocationWorker.perform_async(mobile , store_key, kol_uuid)
        else
          Rails.cache.write(store_keys, 0.5)
        end
      end
      Rails.logger.info  store_keys
      loop_times = 0
      loop_seconds = 0.4
      scores = []
      while  true
        scores = []
        store_keys.each{|t| scores << Rails.cache.read(t)}
        break if loop_times >= 14 ||  scores.compact.size >= cal_mobiles_size * 0.8
        loop_times += 1
        sleep loop_seconds
      end
      Rails.logger.info  scores
      return scores.compact
    end

    def self.contact_score(kol_uuid)
      Rails.cache.read(contact_key(kol_uuid))
    end

    # 有上传联系人后需要init，报道下，计算价值时候看看是否需要以你为依据
    def self.init_contact(kol_uuid)
      Rails.cache.write(contact_key(kol_uuid), -1, :expires_in => 1.days)    if  Rails.cache.read(contact_key(kol_uuid)).nil?
    end

    # 联系人 价值   存储key
    def self.contact_key(kol_uuid)
      "#{kol_uuid}_contact"
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
