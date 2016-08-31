class CpsMaterial < ActiveRecord::Base
  validates_uniqueness_of :sku_id
  before_create :cal_commision, :cal_kol_commision

  scope :enabled, -> {where(:enabled => true)}

  #TODO
  Categories = {food: '美食', clothing: '服饰', beauty: '美妆', digital: '数码', books: '图书'}
  BaseTax = 0.3
  # 根据url 自动同步信息从
  def self.sync_info_from_api(urls = [])
    sku_ids = []
    urls.each do |url|
      sku_id = url.split("/").last.split(".").first rescue nil
      sku_ids << sku_id if sku_id.present?
    end
    exist_sku_ids = CpsMaterial.where(:sku_id => sku_ids).collect{|t| t.sku_id}
    need_sync_sku_ids =   sku_ids - exist_sku_ids
    return if need_sync_sku_ids.size == 0
    res = Jd::Service.get_goods_info(need_sync_sku_ids)
    if res['sucessed'] == true
      res['result'].each do |item|
        CpsMaterial.create!(sku_id: item['skuId'], img_url: item['imgUrl'], material_url: item['materialUrl'], shop_id: item['shopId'], unit_price: item['unitPrice'],
                            start_date: get_time(item['startDate']), end_date: get_time(item['endDate']), goods_name: item['goodsName'],
                            commision_ration_pc: item['commisionRatioPc'], commision_ration_wl: item['commisionRatioWl'], last_sync_at: Time.now )
      end
    else
      Rails.logger.info "======sync_info_from_api----not successful"
    end
  end

  # 换取真实时间
  def self.get_time(offset_time)
    Time.at(offset_time / 1000)
  end

  # PC 上商品详情页
  def get_pc_url
    "http://item.jd.com/#{self.sku_id}.html"
  end

  # wl 上商品详情页
  def get_wl_url
    "http://item.m.jd.com/product/#{self.sku_id}.html"
  end

  def cal_commision
    self.commision_pc = (self.unit_price *  commision_ration_pc * 0.01).round(2)
    self.commision_wl = (self.unit_price *  commision_ration_wl * 0.01).round(2)
  end

  def cal_kol_commision
    self.kol_commision_pc = (self.unit_price *  commision_ration_pc * (1 - BaseTax) * 0.01).round(2)
    self.kol_commision_wl = (self.unit_price *  commision_ration_wl * (1 - BaseTax) * 0.01).round(2)
  end
end
