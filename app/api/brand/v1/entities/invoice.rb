module Brand
  module V1
    module Entities
      class Invoice < Entities::Base
        expose :title, :invoice_type, :taxpayer_id, :company_name, :company_address, :company_mobile, :bank_name,
               :bank_account
      end
    end
  end
end
