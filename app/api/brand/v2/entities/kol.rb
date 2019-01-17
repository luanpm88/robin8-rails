module Brand
  module V2
    module Entities
      class Kol < Entities::Base
        expose profile, using: Entities::CreationSelectedKol
        expose :tenders, using: Entities::Tender do |object, opts|
          Tender.where(creation_id: object.creation_id, kol_id: object.kol_id)
        end
      end
    end
  end
end
