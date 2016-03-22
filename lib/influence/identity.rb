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
    FollowerScoreLevels = [{:min_count => 100000, :score => 100},
                          {:min_count => 50000, :score => 90},
                          {:min_count => 10000, :score => 80},
                          {:min_count => 5000, :score => 70},
                          {:min_count => 1000, :score => 60},
                          {:min_count => 800, :score => 50},
                          {:min_count => 500, :score => 40},
                          {:min_count => 300, :score => 30},
                          {:min_count => 100, :score => 20},
                          {:min_count => 50, :score => 10},
                          {:min_count => -1, :score => 0}]
    def self.cal_follower_score(identity)
      count = identity.followers_count
      FollowerScoreLevels.each do |level|
        return level[:score] if  count > level[:min_count]
      end
    end

    #计算 微博数 得分
    StatusesScoreLevels = [{:min_count => 10000, :score => 100},
                            {:min_count => 5000, :score => 45},
                            {:min_count => 3000, :score => 40},
                            {:min_count => 2000, :score => 35},
                            {:min_count => 1000, :score => 40},
                            {:min_count => 800, :score => 25},
                            {:min_count => 500, :score => 20},
                            {:min_count => 300, :score => 15},
                            {:min_count => 100, :score => 10},
                            {:min_count => 50, :score => 5},
                            {:min_count => -1, :score => 0}]
    def self.cal_status_score(identity)
      count = identity.statuses_count
      StatusesScoreLevels.each do |level|
        return level[:score] if  count > level[:min_count]
      end
    end

    #计算 注册时长 得分
    RegisterScoreLevels = [{:min_count => 5, :score => 30},
                            {:min_count => 4, :score => 25},
                            {:min_count => 3, :score => 20},
                            {:min_count => 2, :score => 15},
                            {:min_count => 1, :score => 10},
                            {:min_count => -1, :score => 0}]
    def self.cal_register_score(identity)
      registered_at = identity.registered_at   rescue nil
      registered_day = (Time.now - registered_at) / (24 * 60 * 60)
      count = registered_day / 365.0          # 注册多少年
      RegisterScoreLevels.each do |level|
        return level[:score] if  count > level[:min_count]
      end
    end

    #计算 认证状态 得分
    VerifyScoreLevels = [{:status => true, :score => 100},
                         {:status => false, :score => 0}]
    def self.cal_verify_score(identity)
      verified = identity.verified
      VerifyScoreLevels.each do |level|
        return level[:score] if  verified == level[:status]
      end
      return 0
    end
  end
end
