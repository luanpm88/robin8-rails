module API
  module V2_1
    module Entities
      module BaseInfoEntities
        class Terrace < Grape::Entity
          expose :id, :name, :address
        end

        class Circle < Grape::Entity
        	expose :id, :name
        end
      end
    end
  end
end
