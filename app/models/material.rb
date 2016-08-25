class Material < ActiveRecord::Base
  validates_uniqueness_of :sku_id

  # 根据url 自动同步信息从
  def self.sync_info_from_api(urls)
    url_arr = urls.split(",")
    if url_arr.size >= 100

    end
    sku_ids = []
    urls.each do |url|
      sku_id = url.split("/").last.split(".").first rescue nil
      sku_ids << sku_id if sku_id.present?
    end
    exist_sku_ids = Material.where(:sku_id => sku_ids).collect{|t| t.sku_id}
    res = Jd::Service.get_goodsInfo(sku_ids - exist_sku_ids)
    if res['successed'] == true
      res['result'].each do |item|
        t.float :commision_ration_pc
        t.float :commision_ration_wl
        t.datetime :last_sync_at
        Material.create!(sku_id: item['skuId'], img_url: item[''], material_url: item['materialUrl'], shop_id: item['shopId'], unit_price: item['unitPrice'],
                    start_date: get_time(item['startDate']), end_date: get_time(item['endDate']),goods_name: item['goodsName'],
                    :commision_ration_pc => item['commisionRatioPc'], commision_ration_wl: item['commisionRatioWl'],)
      end
    else
      Rails.logger.info "======sync_info_from_api----not successful"
    end
  end

  def self.get_time(offset_time)
    Time.at(offset_time / 1000)
  end

  def get_pc_url
    "http://item.jd.com/#{self.sku_id}.html"
  end

  def get_wl_url
    "http://item.m.jd.com/product/#{self.sku_id}.html"
  end
end
