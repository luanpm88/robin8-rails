module Brand
  module V1
    module Entities
      class Transaction < Entities::Base
        expose :id
        expose :item_type
        expose :subject
        expose :budget do |object|
          object.item.try(:budget)
        end
        expose :credits do |object|
          if object.direct == 'income'
            "+#{object.credits}"
          elsif object.direct == 'payout'
            "-#{object.credits}"
          end
        end
        expose :credit do |object|
          (object.item.try(:budget) - object.credits) * 10
        end
        expose :direct do |object|
          if object.direct == 'income' && object.subject == "campaign_tax"
            "退还佣金"
          elsif object.direct == 'income' && object.subject == "campaign_revoke"
            "活动取消退还"
          elsif object.direct == 'income'
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
