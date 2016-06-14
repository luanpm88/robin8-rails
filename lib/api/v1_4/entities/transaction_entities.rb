# kol 的brand
# 充值
# 活动付款(余额、支付宝)
# 活动退款

# kol 
# 活动抵扣
# 活动抵扣退款

module API
  module V1_4
    module Entities
      module TransactionEntities
        class TransactionEntity <  Grape::Entity
          expose :id
          expose :item_type
          expose :subject
          expose :credits do |object|
            if object.direct == 'income'
              "+#{object.credits}"
            elsif object.direct == 'payout'
              "-#{object.credits}"
            end
          end
          expose :direct do |object|
            if object.direct == 'income'
              "充值"
            elsif object.direct == 'payout'
              "活动消耗"
            end
          end
          expose :avail_amount
          expose :trade_no
          expose :created_at do |object|
            object.created_at.strftime("%Y.%m.%d")
          end
          expose :remark do |object|
            object.get_subject
          end
        end
      end
    end
  end
end
