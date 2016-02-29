module API
  module V1
    module Entities
      module CityEntities
        class Summary < Grape::Entity
          expose :name, :name_en
        end
      end
    end
  end
end
