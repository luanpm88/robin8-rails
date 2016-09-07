module Users
  module PromotionHelper
    extend ActiveSupport::Concern

    included do
      after_create :build_promotion_for_new_brand_user
    end

    # 9月新品牌主送50元活动，过期移除掉
    def build_promotion_for_new_brand_user
      return unless Time.now < Date.new(2016, 10, 1)

      kol = user.kol
      transaction = user.income(50, subject: "limited_discount")
      Emay::SendSms.to([kol.mobile_number], "恭喜！您的Robin8品牌主账号已创建成功，50元红包已到账，可直接抵扣。")
      PushMessage.push_common_message([kol], "Robin8品牌主账号50元红包已到账，请查收", "恭喜您成功开通Robin8品牌主账号", transaction)
    end
  end
end