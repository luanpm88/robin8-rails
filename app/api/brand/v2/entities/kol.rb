module Brand
  module V2
    module Entities
      class Kol < Entities::Base
        expose :profile, using: Entities::CreationSelectedKol do |object, opts|
          object
        end
        expose :tenders, using: Entities::Tender do |object, opts|
          ::Tender.where(creation_id: object.creation_id, kol_id: object.kol_id)
        end
      end
    end
  end
end
