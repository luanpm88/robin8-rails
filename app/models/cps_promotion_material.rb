class CpsPromotionMaterial < ActiveRecord::Base
  validates_uniqueness_of :cps_material_id, :scope => [:kol_id, :cps_article_share_id]

  # 获取kol商品促销url
  def self.get_promotion_url(share_id, material_id)
    cps_article_share = CpsArticleShare.find share_id   rescue nil
    material = CpsMaterial.find material_id  rescue nil
    return nil if cps_article_share.blank? || material.blank?
    promotion_material = CpsPromotionMaterial.find_or_initialize_by(:cps_article_share_id => share_id, :cps_material_id => material_id)
    if promotion_material.new_record?
      sub_union_id = CpsArticleShare.get_sub_uniond_id(cps_article_share.kol_id, share_id)
      url = Jd::Service.get_code(sub_union_id, material.get_wl_url)
      promotion_material.kol_id = cps_article_share.kol_id
      promotion_material.wl_promotion_url = url
      promotion_material.save
    end
    promotion_material.wl_promotion_url
  end
end
