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

          expose :created_at do |object|
            object.created_at.strftime("%m-%d")
          end

          expose :title do |object|
            if object.item_type == "Campaign"
              object.item.name
            else
              "账户充值"
            end
          end

          expose :credits do |object|
            if object.direct == 'income'
              "+#{object.credits}"
            elsif object.direct == 'payout'
              "-#{object.credits}"
            end
          end

          expose :pay_way do |object|
            if object.direct == 'payout' and object.item_type == "Campaign"
              object.item.pay_way
            else
              ""
            end
          end
          
          expose :direct_text do |object|
            if object.direct == 'income'
              if object.item_type == "Campaign"
                "活动退款"
              else
                "充值"
              end
            elsif object.direct == 'payout'
              "活动付款"
            end
          end
        end
      end
    end
  end
end
