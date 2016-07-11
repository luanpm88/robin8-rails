module API
  module V1_5
    module Entities
      module NlpServiceEntities
        class Category <  Grape::Entity
          expose :text do |cate|
            cate['text']
          end
          expose :weight do |cate|
            cate['weight'].round(3)  rescue 0
          end
        end
      end
    end
  end
end
