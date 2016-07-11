module API
  module V1_5
    module Entities
      module HotItemEntities
        class Summary <  Grape::Entity
          expose :id, :title, :read_url
          expose :publish_at do |hot_item|
            hot_item.publish_at.to_date rescue hot_item.publish_at
          end
        end
      end
    end
  end
end
