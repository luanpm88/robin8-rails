module Brand
  module V2
    module Entities
      class Kol < Entities::Base
        expose :tenders, using: Entities::Tender
      end
    end
  end
end
