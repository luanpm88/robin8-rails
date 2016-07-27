module API
  module V1_6
    module Entities
      module ProfessionEntities
        class Summary < Grape::Entity
          expose :name, :label
        end
      end
    end
  end
end
