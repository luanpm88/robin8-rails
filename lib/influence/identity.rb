module Influence
  class Identity
    def self.get_identity_score(kol_uuid)
      identity_score = 0
      max_score_identity = TmpIdentity.where(:kol_uuid => kol_uuid).order("score desc").first
      identity_score = max_score_identity.score || 0 rescue 0
      TmpKolInfluenceItem.store_item(kol_uuid, 'identity', identity_score, identity_score, max_score_identity.to_json)
      identity_score
    end

    def self.cal_score(kol_uuid,identity_id)
      identity = TmpIdentity.find identity_id
      return 0 if identity.blank?
      total_score = cal_follower_score(identity) + cal_status_score(identity) +  cal_register_score(identity) +  cal_verify_score(identity)
      identity.update_column(:score, total_score)
    end

    #计算 微博粉丝 得分
    def self.cal_follower_score(identity)
      count = identity.followers_count || 0  rescue 0
      score = (20 * Math.log10(count)).round(0)
      score  = 100 if score > 100
      score
    end

    #计算 微博数 得分
    def self.cal_status_score(identity)
      count = identity.statuses_count  || 0  rescue 0
      score = (12.5 * Math.log10(count)).round(0)
      score  = 50 if score > 50
      score
    end

    #计算 注册时长 得分
    def self.cal_register_score(identity)
      registered_at = identity.registered_at  || Time.now  rescue  Time.now
      registered_day = (Time.now - registered_at) / (24 * 60 * 60)
      count = registered_day / 30         # 注册多少月
      score = (15 * Math.log10(count)).round(0)
      score = 30 if score > 30
      score
    end

    #计算 认证状态 得分
    def self.cal_verify_score(identity)
      verified = identity.verified rescue false
      score = (verified == true ? 50 : 0)
      score
    end
  end
end
