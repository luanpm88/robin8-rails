class CpsMaterial < ActiveRecord::Base
  validates_uniqueness_of :sku_id
  before_create :cal_commision, :cal_kol_commision

  scope :enabled, -> {where(:enabled => true)}
  scope :hot, -> {where(:is_hot => true)}
  scope :order_overall, -> {order("is_hot desc, position desc, id desc")}
  scope :order_price_desc, -> {order("unit_price desc")}
  scope :order_price_asc, -> {order("unit_price asc")}
  scope :order_commission_desc, -> {order("commision_ration_wl desc")}
  scope :order_commission_asc, -> {order("commision_ration_wl asc")}

  #TODO
  Categories =  ["手机", "家具", "珠宝首饰", "影视", "厨具", "音乐", "玩具乐器", "家用电器", "礼品箱包", "服饰内衣", "家居家装", "运动户外", "养生保健",
                 "医药保健", "宠物生活", "鞋靴", "教育音像", "电脑和办公", "性福生活", "酒类", "食品饮料", "汽车用品", "家用器械", "个护化妆", "母婴", "图书", "钟表"]

  def self.get_category_field
    Categories.collect{|key| [ key, key]}
  end

  # 根据url 自动同步信息从
  def self.sync_info_from_api(urls = [], category)
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
                            commision_ration_pc: item['commisionRatioPc'], commision_ration_wl: item['commisionRatioWl'], last_sync_at: Time.now, category: category )
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
    self.kol_commision_pc = (self.unit_price *  commision_ration_pc * (1 - Jd::Settle::PlatformTax) * 0.01).round(2)
    self.kol_commision_wl = (self.unit_price *  commision_ration_wl * (1 - Jd::Settle::PlatformTax) * 0.01).round(2)
  end
end
