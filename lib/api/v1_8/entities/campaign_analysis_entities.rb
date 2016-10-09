module API
  module V1_4
    module Entities
      module CampaignAnalysisEntities
        class Summary < Grape::Entity
          expose :name do |effect|
            effect.key
          end
          expose :label do |effect|
            effect.value
          end
        end
      end
    end
  end
end
