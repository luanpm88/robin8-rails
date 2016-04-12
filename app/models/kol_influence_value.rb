class KolInfluenceValue < ActiveRecord::Base
  #计算总价值
  BaseScore = 380
  def self.cal_and_store_score(kol_id, kol_uuid, kol_city, kol_mobile_model, is_auto = false)
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
    kol_value.location_score = Influence::Other.kol_location_score(kol_uuid,kol_city)    if kol_city
    kol_value.mobile_model_score = Influence::Other.mobile_model_score(kol_uuid, kol_mobile_model)   if kol_mobile_model
    kol_value.identity_score = Influence::Identity.get_identity_score(kol_uuid)
    kol_value.identity_count_score = Influence::Other.identity_count_score(kol_uuid)
    kol_value.contact_score = Influence::Contact.cal_score(kol_uuid,kol_id)
    kol_value.influence_score = get_total_score(kol_value)
    kol_value.influence_level = Influence::Value.get_influence_level(kol_value.influence_score)
    kol_value.name = TmpIdentity.get_name(kol_uuid, kol_id)
    kol_value.avatar_url = TmpIdentity.get_avatar_url(kol_uuid, kol_id)
    kol_value.save
    KolInfluenceValueHistory.generate_history(kol_value, is_auto)
    kol_value
  end

  def self.get_total_score(kol_value)
    BaseScore + kol_value.location_score + kol_value.mobile_model_score + kol_value.identity_score +
      kol_value.contact_score +  kol_value.identity_count_score  + kol_value.campaign_total_click_score +
      kol_value.campaign_avg_click_score +  kol_value.article_total_click_score +  kol_value.article_avg_click_score
  end

  def self.get_score(kol_uuid, current_kol = nil)
    return  KolInfluenceValue.find_by :kol_uuid => kol_uuid    rescue nil
  end

  ItemBaseScore = 76
  def get_item_scores
    feature_score =  ItemBaseScore + location_score +  mobile_model_score  +  identity_count_score  +  verify_score
    active_score =  ItemBaseScore + follower_score + status_score + register_score
    campaign_score = ItemBaseScore + campaign_avg_click_score + campaign_total_click_score
    share_score = ItemBaseScore + article_avg_click_score + article_total_click_score
    contact_score = ItemBaseScore + contact_score
    rate = {}
    rate[:feature_rate] =  (feature_score / 216.0).round(2)
    rate[:active_rate] =  (feature_score / 256.0).round(2)
    rate[:campaign_rate] =  (feature_score / 176.0).round(2)
    rate[:share_rate] =  (feature_score / 176.0).round(2)
    rate[:contact_rate] =  (feature_score / 176.0).round(2)
    rate
  end
end
