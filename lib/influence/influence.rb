module Influence
  class Influence
    #https://robin8.atlassian.net/wiki/display/RPM/KOL+Influence+Scoring+Algorithm
    #计算总价值
    # kol_uuid_contact = {:exist => true, :hunder_score => 0}
    # kol_uuid_identity = {:exist => true, :hunder_score => 0}
    Rate = {:follower_rate => 0.3, :status_rate => 0.15, :register_rate => 0.05, :verify_rate => 0.1, :contact_rate => 0.4 }
    IdentityTotalRate = Rate[:follower_rate] + Rate[:status_rate] + Rate[:register_rate] + Rate[:cal_verify_score]
    def self.get_total_score(kol_uuid)
      wait_cal_score(kol_uuid)
      score = 0
      if  contact_score(kol_uuid) != -1  &&  identity_score(kol_uuid) != -1
        score = contact_score(kol_uuid) * IdentityTotalRate +  identity_score(kol_uuid) * Rate[:contact_rate]
      elsif contact_score(kol_uuid) != -1
        score = contact_score(kol_uuid) * 0.8
      elsif  identity_score(kol_uuid) != -1
        score = identity_score(kol_uuid) * 0.8
      end
      score * 100
    end

    #等待后台计算
    LoopTimes = 40
    LoopSecond = 0.1
    def self.wait_cal_score(kol_uuid)
      loop_times = 0
      ok = false
      while loop_time < LoopTimes && !ok
        ok = true if  contact_score(kol_uuid) != -1 && identity_score(kol_uuid) != -1
        sleep LoopSecond
        loop_times += 1
      end
    end

    def self.contact_score(kol_uuid)
      Rails.cache.read(contact_key(kol_uuid))
    end

    def self.identity_score(kol_uuid)
      Rails.cache.read(identity_key(kol_uuid))
    end

    # 有上传联系人后需要init，报道下，计算价值时候看看是否需要以你为依据
    def self.init_contact(kol_uuid)
      Rails.cache.write(contact_key(kol_uuid), -1)    if  Rails.cache.read(contact_key(kol_uuid)).nil?
    end

    # 有identity 进入后需要init，最终作为是否纳入总价值的依据
    def self.init_identity(kol_uuid)
      Rails.cache.write(identity_key(kol_uuid), -1)  if  Rails.cache.read(identity_key(kol_uuid)).nil?
    end

    # 联系人 价值   存储key
    def self.contact_key(kol_uuid)
       "#{kol_uuid}_contact"
    end

    # 社交账号 价值  存储key
    def self.identity_key(kol_uuid)
      "#{kol_uuid}_identity"
    end
  end
end
