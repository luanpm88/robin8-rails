class CpsPromotionMaterial < ActiveRecord::Base
  validates_uniqueness_of :cps_material_id, :scope => [:kol_id, :cps_article_share_id]

  def self.get_promotion_url(kol_id, share_id, material_id)
    promotion_material = CpsPromotionMaterial.find_or_initialize_by(:kol_id => kol_id, :share_id => share_id, :material_id => material_id)
    if promotion_material.blank?
      sub_union_id = CpsArticleShare.get_sub_uniond_id(kol_id, share_id)
      material = CpsMaterial.find material_id
      return if material.blank?
      url = Jd::Service.get_code(sub_union_id, material.get_wl_url)
      promotion_material.wu_promotion_url = url
      promotion_material.save
    end
    promotion_material.wu_promotion_url
  end
end
