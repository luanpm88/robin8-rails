module API
  module V1
    module Entities
      module CampaignInviteEntities
        class Summary < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :status, :img_status, :share_url, :is_invited, :screenshot, :reject_reason
          with_options(format_with: :iso_timestamp) do
            expose :approved_at
          end
          expose :can_upload_screenshot
          expose :avail_click do |campaign_invite|
            campaign_invite.get_avail_click
          end
          expose :total_click do |campaign_invite|
            campaign_invite.get_total_click
          end
          expose :earn_money
          expose :tag
          expose :campaign, using: API::V1::Entities::CampaignEntities::Summary    if  lambda { |instance, options| instance.campaign.present? }
        end
      end
    end
  end
end
