module API
  module V1
    module Entities
      module CampaignEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :message, :per_budget_type, :per_action_budget, :budget, :max_action
          expose :url do |campaign|
            campaign.url.gsub("#rd","").gsub("#wechat_redirect","")   rescue campaign.url
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
          expose :take_budget
          expose :remain_budget
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
          with_options(format_with: :iso_timestamp) do
            expose :recruit_start_time
            expose :recruit_end_time
          end
        end
      end
    end
  end
end
