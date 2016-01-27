module API
  module V1
    module Entities
      module CampaignInviteEntities
        class Summary < Grape::Entity
          expose :status, :img_status, :share_url, :campaign_id, :kol_id, :is_invited
          expose :avail_click do |campaign_invite|
            campaign_invite.get_avail_click
          end
          expose :total_click do |campaign_invite|
            campaign_invite.get_total_click
          end
          expose :earn_money
          expose :campaign, using: API::V1::Entities::CampaignEntities::Summary    if  lambda { |instance, options| instance.campaign.present? }
        end
      end
    end
  end
end
