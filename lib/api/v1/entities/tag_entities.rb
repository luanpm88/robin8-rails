module API
  module V1
    module Entities
      module TagEntities
        class Summary < Grape::Entity
          expose :name, :label, :cover_url
        end
      end
    end
  end
end
