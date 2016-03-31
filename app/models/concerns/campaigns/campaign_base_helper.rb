module Campaigns
  module CampaignBaseHelper
    extend ActiveSupport::Concern
    def img_cover_url
      if self.attributes["img_url"].present? and self.attributes["img_url"].match(/?imageMogr2\/crop\/!/)
        # 新版brand 会裁剪 图片, img_url 中包括了 裁剪的 配置
        # example: http://xxx.jpg?imageMogr2/crop/!892.018779342723x501.7605633802817a0a0"
        return self.attributes["img_url"]
      end
      self.img_url.gsub("-400","") + "!cover2"     rescue nil
    end
  end
end