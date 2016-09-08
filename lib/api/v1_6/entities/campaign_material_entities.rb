module API
  module V1_6
    module Entities
      module CampaignMaterialEntities
        class Summary < Grape::Entity
          expose :url_type
          expose :url do |campaign_material, options|
            CampaignMaterial.get_track_url(campaign_material, options[:kol].id)
          end
        end
      end
    end
  end
end
