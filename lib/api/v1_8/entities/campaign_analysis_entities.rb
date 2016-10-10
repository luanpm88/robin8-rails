module API
  module V1_8
    module Entities
      module CampaignAnalysisEntities
        class AnalysisInfo < Grape::Entity
          expose :text do  |object|
            object[:text]
          end
          expose :keywords do |object|
            object[:keywords]
          end
          expose :sentiment do |object|
            object[:sentiment]
          end
          expose :persons_brands do |object|
            object[:persons_brands]
          end
          expose :products do |object|
            object[:products]
          end
        end
      end
    end
  end
end
