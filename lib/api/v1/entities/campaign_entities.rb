module API
  module V1
    module Entities
      module CampaignEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :message, :max_action, :remark, :wechat_auth_type
          expose :cpi_example_screenshot do |campaign|
            campaign.get_example_screenshot
          end
          expose :cpi_example_screenshots do |campaign|
            [campaign.get_example_screenshot(true)]
          end
          expose :per_budget_type do |campaign|
            if campaign.is_cpi_type?
              'cpa'
            else
              campaign.per_budget_type
            end
          end
          expose :per_action_type do |campaign|
            if campaign.is_cpi_type?
              'cpi'
            else
               campaign.sub_type
            end
          end
          expose :url do |campaign|
            campaign.url.gsub("#rd","").gsub("#wechat_redirect","")   rescue campaign.url
          end
          expose :per_action_budget do |campaign, options|
            if campaign.is_invite_type?
              options[:campaign_invite].price
            else
              campaign.get_per_action_budget(false)
            end
          end
          expose :budget do |campaign|
            campaign.actual_budget(false).round(0)
          end
          expose :img_url do |campaign|
            campaign.img_cover_url
          end
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
          expose :brand_name do |campaign|
            campaign.user.name || campaign.user.company   rescue nil
          end
          expose :avail_click do |campaign|
            campaign.get_avail_click
          end
          expose :total_click do |campaign|
            campaign.get_total_click
          end
          expose :take_budget do |campaign|
            campaign.take_budget(false)
          end
          expose :remain_budget do |campaign|
            campaign.remain_budget(false)
          end
          expose :share_times
          expose :interval_time do |campaign|
            if campaign.is_recruit_type?
              interval_time(Time.now, campaign.recruit_end_time)
            else
              interval_time(Time.now, campaign.deadline)
            end
          end
          expose :address
          expose :hide_brand_name
          expose :task_description
          expose :action_desc
          with_options(format_with: :iso_timestamp) do
            expose :recruit_start_time
            expose :recruit_end_time
          end
        end
      end
    end
  end
end
