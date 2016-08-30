class CpsArticleShare < ActiveRecord::Base
  has_many :cps_promotion_materials
  belongs_to :cps_article

  def self.get_sub_uniond_id(kol_id, article_share_id)
    "#{kol_id}_#{article_share_id}"
  end

  # 用户分享文章,自动生成推广链接
  def self.kol_share_article(kol = Kol.last, article = CpsArticle.last)
    return if kol.blank? || article.blank?
    CpsArticleShare.transaction do
      article_share = CpsArticleShare.create!(kol_id: kol.id, cps_article_id: article.id)
      article.cps_materials.each do |material|
        wl_promotion_url = Jd::Service.get_code(get_sub_uniond_id(kol.id, article_share.id),material.get_wl_url)
        next if wl_promotion_url.blank?
        article_share.cps_promotion_materials.create!(kol_id: kol.id, cps_article_share_id: article.id, cps_material_id: material.id,
                                                      wl_promotion_url: wl_promotion_url )
      end
    end
  end

  def get_article_author
    CpsArticle
  end


  #测试数据
  def self.create_article_data
    article = CpsArticle.new(:kol_id => 79, :body => "测试数据,自动生成")
    CpsMaterial.first(2).each do |material|
      article.cps_article_materials.build(:cps_material_id => material.id)
    end
    article.save
  end
end
