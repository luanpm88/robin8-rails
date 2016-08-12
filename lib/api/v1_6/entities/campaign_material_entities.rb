module API
  module V1_6
    module Entities
      module CampaignMaterialEntities
        class Summary < Grape::Entity
          expose :url_type, :url
        end
      end
    end
  end
end
