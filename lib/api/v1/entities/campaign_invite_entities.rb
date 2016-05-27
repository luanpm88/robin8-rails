module API
  module V1
    module Entities
      module CampaignInviteEntities
        class Summary < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :status, :img_status, :is_invited, :screenshot, :reject_reason , :uuid
          expose :share_url do |campaign_invite|
            campaign_invite.origin_share_url
          end
          with_options(format_with: :iso_timestamp) do
            expose :approved_at
          end
          expose :start_upload_screenshot
          expose :can_upload_screenshot
          expose :avail_click do |campaign_invite|
            campaign_invite.get_avail_click
          end
          expose :total_click do |campaign_invite|
            campaign_invite.get_total_click
          end
          expose :earn_money
          expose :tag
          expose :upload_interval_time
          expose :ocr_status do |campaign_invite|
            true
            # if campaign_invite.ocr_status == 'passed'
            #   true
            # elsif campaign_invite.ocr_status == 'failure'
            #   false
            # else
            #   nil
            # end
          end
          expose :ocr_detail do |campaign_invite|
            campaign_invite.get_ocr_detail
          end
          expose :invite_status
          expose :campaign, using: API::V1::Entities::CampaignEntities::Summary    if  lambda { |instance, options| instance.campaign.present? }
        end
      end
    end
  end
end
