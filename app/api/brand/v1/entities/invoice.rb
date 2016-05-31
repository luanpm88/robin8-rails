module Brand
  module V1
    module Entities
      class Invoice < Entities::Base
        expose :title, :invoice_type
      end
    end
  end
end
