module API
  module V3_0
    module Entities
      module CreationEntities
        class BaseInfo < Grape::Entity
          expose :id, :name, :description, :img_url, :user_id
        end
      end
    end
  end
end
