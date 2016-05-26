module Brand
  module V1
    module Entities
      class InvoiceReceiver < Entities::Base
        expose :name, :phone_number, :address
      end
    end
  end
end
