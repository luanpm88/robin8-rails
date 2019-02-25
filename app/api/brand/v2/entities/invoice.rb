module Brand
  module V2
    module Entities
      class Invoice < Entities::Base
        expose :title, :invoice_type, :taxpayer_id, :company_address, :company_mobile, 
               :bank_name, :bank_account
      end
    end
  end
end
