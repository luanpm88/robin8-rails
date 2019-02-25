module Brand
  module V2
    module Entities
      class InvoiceReceiver < Entities::Base
        expose :name, :phone_number, :address
      end
    end
  end
end
