class KolInfluenceValue < ActiveRecord::Base
  #计算总价值
  BaseScore = 500
  def self.cal_and_store_score(kol_id, kol_uuid, kol_city, kol_mobile_model)
    kol_city = Influence::Value.get_kol_city(kol_uuid)   if kol_city.blank?
    kol_value = KolInfluenceValue.find_or_initialize_by(:kol_uuid => kol_uuid)
    kol_value.kol_id = kol_id
    kol_value.location_score = Influence::Other.kol_location_score(kol_uuid,kol_city)
    kol_value.mobile_model_score = Influence::Other.mobile_model_score(kol_uuid, kol_mobile_model)
    kol_value.identity_score = Influence::Identity.get_identity_score(kol_uuid)
    kol_value.identity_count_score = Influence::Other.identity_count_score(kol_uuid)
    contact_score  =   kol_value.contact_score ||  Influence::Value.get_contact_score(kol_uuid)
    kol_value.contact_score = contact_score
    total_score =  BaseScore + kol_value.location_score + kol_value.mobile_model_score + kol_value.identity_score +
      kol_value.contact_score +  kol_value.identity_count_score
    kol_value.influence_score = total_score
    kol_value.influence_level = Influence::Value.get_influence_level(total_score)
    kol_value.name = TmpIdentity.get_name(kol_uuid, kol_id)
    kol_value.avatar_url = TmpIdentity.get_avatar_url(kol_uuid, kol_id)
    kol_value.save
    kol_value
  end

  def self.get_score(kol_uuid, current_kol = nil)
    return  KolInfluenceValue.find_by :kol_uuid => kol_uuid    rescue nil
    # kol_value = KolInfluenceValue.where(:kol_id => current_kol.id).order("id desc").first     rescue nil if current_kol && kol_value.blank?
    # kol_value
  end
end
