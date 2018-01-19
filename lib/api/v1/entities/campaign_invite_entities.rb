module API
  module V1
    module Entities
      module CampaignInviteEntities
        class Summary < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :status, :img_status, :is_invited, :reject_reason , :uuid, :price, :sale_price , :sub_type
          expose :screenshot do |campaign_invite|
            screenshot = campaign_invite.screenshot
          end
          expose :screenshots do |campaign_invite|
            campaign_invite.get_multi_screenshots
          end
          expose :share_url do |campaign_invite|
            campaign_invite.visit_url
            # campaign_invite.origin_share_url
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
          end
          expose :ocr_detail do |campaign_invite|
            ''
          end
          expose :invite_status
          expose :cpi_example_screenshot do |campaign_invite|
            campaign_invite.get_example_screenshot
          end
          expose :cpi_example_screenshots do |campaign_invite|
            [campaign_invite.get_example_screenshot(true)]
          end
          expose :screenshot_comment do |campaign_invite|
            campaign_invite.campaign.comment.split("&")  rescue []
          end
          expose :campaign do |campaign_invite, options|
            API::V1::Entities::CampaignEntities::Summary.represent campaign_invite.campaign, options.merge({campaign_invite: campaign_invite})
          end
        end

        class MyCampaigns < Grape::Entity
          expose  :id , :campaign_id , :status , :img_status , :screenshot , :reject_reason , :earn_money 
          expose  :campaign_name do |my_campaigns|
            my_campaigns.campaign.name
          end
          expose :per_action_type do |my_campaign|
            if my_campaign.campaign.is_cpi_type?
              'cpi'
            else
              my_campaign.campaign.sub_type
            end
          end
          expose :per_budget_type do |my_campaign|
            if my_campaign.campaign.is_cpi_type?
              'cpa'
            else
               my_campaign.campaign.per_budget_type
            end
          end
        end
      end
    end
  end
end
