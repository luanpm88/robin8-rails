module Brand
  module V1
    module Entities
      class InvoiceHistory < Entities::Base
        expose :credits, :invoice_type, :title, :address, :status
        expose :created_at do |object|
          object.created_at.strftime('%Y年%m月%d日')
        end
      end
    end
  end
end
