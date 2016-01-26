module API
  module V1
    module Entities
      module CampaignInviteEntities
        class Summary < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :name, :description, :img_url, :status, :message, :url, :per_budget_type, :per_action_budget, :budget
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
            expose :remain_time
          end
          expose 'avail_click' do |campaign|
            campaign.get_avail_click
          end
          expose 'total_click' do |campaign|
            campaign.get_total_click
          end
          expose 'take_budget' do |campaign|
            campaign.take_budget
          end
          expose 'remain_budget' do |campaign|
            campaign.remain_budget
          end
          expose 'share_time' do |campaign|
            campaign.get_share_time
          end
        end
      end
    end
  end
end
