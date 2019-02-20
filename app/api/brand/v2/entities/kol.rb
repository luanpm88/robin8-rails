module Brand
  module V2
    module Entities
      class Kol < Entities::Base
        expose :profile, using: Entities::CreationSelectedKol do |object, opts|
          object
        end
        expose :tenders, using: Entities::Tender do |object, opts|
          object.tenders
        end
      end
    end
  end
end
