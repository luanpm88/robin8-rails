module Brand
  module V2
    module Entities
      class InvoiceHistory < Entities::Base
        expose :credits, :invoice_type, :title, :address, :status, :tracking_number
        
        expose :created_at do |object|
          object.created_at.strftime('%Y年%m月%d日')
        end

        expose :status_zh do |object|
          object.status_zh
        end
      end
    end
  end
end
