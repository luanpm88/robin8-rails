module Users
  module PromotionHelper
    extend ActiveSupport::Concern

    included do
      after_create :build_promotion_for_new_brand_user
    end

    # 9月新品牌主送50元活动，过期移除掉
    def build_promotion_for_new_brand_user
      return unless Time.now < Date.new(2016, 10, 1)

      transaction = self.income(50, "limited_discount")
      unless Rails.env.development?
        SmsMessage.send_by_resource_to(self.kol, "恭喜！您的Robin8品牌主账号已创建成功，50元红包已到账，可直接抵扣。", transaction)
        PushMessage.push_common_message([self.kol], "Robin8品牌主账号50元红包已到账，请查收", "恭喜您成功开通Robin8品牌主账号", transaction)
      end
    end
  end
end