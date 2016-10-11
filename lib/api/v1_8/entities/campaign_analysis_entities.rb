module API
  module V1_8
    module Entities
      module CampaignAnalysisEntities
        class AnalysisInfo < Grape::Entity
          expose :text
          expose :keywords
          expose :sentiment
          expose :persons_brands
          expose :products
          expose :cities
          expose :categories
        end
      end
    end
  end
end
