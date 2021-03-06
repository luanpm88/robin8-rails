class CpsArticleShare < ActiveRecord::Base
  include Redis::Objects
  counter :read_count

  has_many :cps_promotion_materials
  has_many :cps_promotion_orders
  has_many :cps_promotion_order_items, :through => :cps_promotion_orders
  # 预计收入
  has_many :cps_promotion_valid_orders, -> {where(:status => ['pending', 'finished', 'part_return'])}, :class_name => 'CpsPromotionOrder'
  has_many :cps_promotion_valid_order_items, :through => :cps_promotion_valid_orders, :source => 'cps_promotion_order_items'
  # 确认收入
  has_many :cps_promotion_settled_orders, -> {where(:status => 'settled')}, :class_name => 'CpsPromotionOrder'
  has_many :cps_promotion_settled_order_items, :through => :cps_promotion_settled_orders, :source => 'cps_promotion_order_items'

  belongs_to :cps_article
  belongs_to :kol

  after_commit :create_promotion_materials

  def share_url
    "#{Rails.application.secrets.domain}/cps_article_shares/#{self.id}"
  end

  def self.get_sub_uniond_id(kol_id, article_share_id)
    "#{kol_id}_#{article_share_id}"
  end

  # 用户分享文章,自动生成推广链接   for test
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
    cps_article.kol
  end


  #测试数据
  def self.create_article_data
    article = CpsArticle.new(:kol_id => 79,
                             :content => "<text>哈哈哈<img>http://www.baidu.com<product>3<product>5<text>哈哈哈<img>http://www.baidu.com<product>3<product>5")
    CpsMaterial.first(2).each do |material|
      article.cps_article_materials.build(:cps_material_id => material.id)
    end
    article.save
  end

  def create_promotion_materials
    cps_article_share = self
    cps_materials = self.cps_article.cps_materials
    return if  cps_materials.size == 0
    sub_uniond_id = CpsArticleShare.get_sub_uniond_id(self.kol_id, self.id)
    ids = cps_materials.collect{|t| t.sku_id}
    urls = cps_materials.collect{|t| t.get_wl_url }
    Jd::Service.get_batch_code(sub_uniond_id, ids, urls).each_with_index do |info, index|
      CpsPromotionMaterial.create(:kol_id => cps_article_share.kol_id, :cps_article_share_id => cps_article_share.id,
                                  :cps_material_id =>  cps_materials[index].id, :wl_promotion_url => info["url"])
    end
  end

  # 获取文章分享 预计佣金
  def share_forecast_commission
    commission = self.cps_promotion_valid_order_items.sum(:yg_cos_fee) * (1 - Jd::Settle::PlatformTax)
    commission.round(2)
  end

  # 获取文章分享 预计佣金
  def share_settled_commission
    commission = self.cps_promotion_settled_order_items.sum(:yg_cos_fee) * (1 - Jd::Settle::PlatformTax)
    commission.round(2)
  end

end
