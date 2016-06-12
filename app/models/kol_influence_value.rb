class KolInfluenceValue < ActiveRecord::Base
  belongs_to :kol


  UpgradeNotices = ["1. 绑定更多的社交账号，提升你的影响力分数","2. 积极参与悬赏活动，增强个人账户的活跃度","3. 邀请更多好友加入Robin8，通过通讯录建立你的朋友圈，精准分析你的影响力"]
  #计算总价值
  BaseScore = 380
  def self.cal_and_store_score(kol_id, kol_uuid, kol_city, kol_mobile_model, is_auto = false)
    kol = Kol.find kol_id  rescue nil
    kol_city = Influence::Value.get_kol_city(kol_uuid)   if kol_city.blank?
    kol_value = KolInfluenceValue.find_or_initialize_by(:kol_uuid => kol_uuid)
    kol_value.base_score = BaseScore
    kol_value.kol_id = kol_id
    best_identity = Influence::Identity.get_best_identity(kol_uuid)
    if best_identity
      kol_value.follower_score = Influence::Identity.cal_follower_score(best_identity)
      kol_value.status_score = Influence::Identity.cal_status_score(best_identity)
      kol_value.register_score = Influence::Identity.cal_register_score(best_identity)
      kol_value.verify_score = Influence::Identity.cal_verify_score(best_identity)
    end
    if kol_id
      kol_value.campaign_total_click_score = Influence::CampaignClick.get_total_click_score(kol_id)
      kol_value.campaign_avg_click_score  = Influence::CampaignClick.get_avg_click_score(kol_id)
      kol_value.article_total_click_score = Influence::ArticleClick.get_total_click_score(kol_id)
      kol_value.article_avg_click_score = Influence::ArticleClick.get_avg_click_score(kol_id)
    end
    kol_value.location_score = Influence::Other.kol_location_score(kol_uuid,kol_city)
    kol_value.mobile_model_score = Influence::Other.mobile_model_score(kol_uuid, kol_mobile_model)     if kol_mobile_model.present?
    kol_value.identity_score = Influence::Identity.get_identity_score(kol_uuid)
    kol_value.identity_count_score = Influence::Other.identity_count_score(kol_uuid)
    kol_value.contact_score = Influence::Contact.cal_score(kol_uuid,kol_id)
    influence_score = cal_total_score(kol_value)
    #如果当前分数没上次高 则不保存，不覆盖。但还是生成历史
    if  kol_value.influence_score.to_i < influence_score
      kol_value.influence_score = influence_score
      kol_value.influence_level = Influence::Value.get_influence_level(kol_value.influence_score)
      kol_value.name = TmpIdentity.get_name(kol_uuid, kol_id)
      kol_value.avatar_url = TmpIdentity.get_avatar_url(kol_uuid, kol_id)
      kol_value.save
    end
    kol.update_influence_result(kol_uuid,kol_value.influence_score, kol_value.updated_at)   if kol.present?
    KolInfluenceValueHistory.generate_history(kol_value, is_auto)
    kol_value
  end

  def self.cal_total_score(kol_value)
    BaseScore + kol_value.location_score + kol_value.mobile_model_score + kol_value.identity_score +
      kol_value.contact_score +  kol_value.identity_count_score  + kol_value.campaign_total_click_score +
      kol_value.campaign_avg_click_score +  kol_value.article_total_click_score +  kol_value.article_avg_click_score
  end

  def self.get_score(kol_uuid, current_kol = nil)
    return  KolInfluenceValue.find_by :kol_uuid => kol_uuid    rescue nil
  end

  def self.get_score_by_kol_id(kol_id)
    KolInfluenceValue.find_by :kol_id => kol_id
  end

  ItemBaseScore = 76
  def get_item_scores
    feature_score =  ItemBaseScore + location_score +  mobile_model_score  +  identity_count_score  +  verify_score
    active_score =  ItemBaseScore + follower_score + status_score + register_score
    campaign_score = ItemBaseScore + campaign_avg_click_score + campaign_total_click_score
    share_score = ItemBaseScore + article_avg_click_score + article_total_click_score
    contacts_score = ItemBaseScore + contact_score
    rate = {}
    rate[:feature_rate] =  (feature_score / 216.0).round(2)
    rate[:active_rate] =  (active_score / 256.0).round(2)
    rate[:campaign_rate] =  (campaign_score / 176.0).round(2)
    rate[:share_rate] =  (share_score / 176.0).round(2)
    rate[:contact_rate] =  (contacts_score / 176.0).round(2)
    puts rate
    rate
  end

  def self.schedule_cal_influence
    return if Date.today.wday !=  Rails.application.secrets[:cal_influence][:wday]
    if Rails.env.development?
      CalInfluenceWorker.new.perform
    else
      CalInfluenceWorker.perform_async
    end
  end

  def self.diff_score(kol_uuid, kol_id = nil, kol_value)
    last_auto = before_kol_value(kol_uuid, kol_id, kol_value)
    if last_auto
      value = KolInfluenceValueHistory.where(:kol_uuid => kol_uuid).last
      diff = value.influence_score.to_i - last_auto.influence_score.to_i  rescue 0
      return "影响力分数#{value.influence_score}分 比上周增加了#{diff}分"
    else
      return nil
    end
  end

  def self.before_kol_value(kol_uuid,kol_id = nil, kol_value = nil)
    return nil if kol_value.nil?
    if kol_id.present?
      KolInfluenceValueHistory.where(:kol_id => kol_id).where("created_at < #{kol_value.to_date}").order("id desc").first   rescue nil
    else
      KolInfluenceValueHistory.where(:kol_uuid => kol_uuid).where("created_at < #{kol_value.to_date}").order("id desc").first   rescue nil
    end
  end

end
