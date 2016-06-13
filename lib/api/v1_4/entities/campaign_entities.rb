module API
  module V1_4
    module Entities
      module CampaignEntities
        class CampaignStatsEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget, :need_pay_amount
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
          expose :avail_click do |campaign|
            campaign.get_avail_click
          end
          expose :total_click do |campaign|
            campaign.get_total_click
          end
          expose :take_budget
          expose :share_times
          expose :stats_data do |campaign|
            campaign.get_stats
          end
        end

        class CampaignAlipayEntity < Grape::Entity
          expose :id, :string
          expose :alipay_url do |campaign|
            campaign.generate_alipay_campaign_order
          end
        end

        class CampaignListEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :need_pay_amount, :status, :img_url, :name
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
        end

        class CampaignPayEntity < Grape::Entity
          expose :id, :need_pay_amount, :status
          expose :brand_amount do |campaign|
            campaign.user.avail_amount.to_f
          end
        end

        class CampaignBalancePayEntity < Grape::Entity
          expose :id, :need_pay_amount, :status
        end

        class CreateCampaignEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
        end

        class UnpayShowEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget, :need_pay_amount
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
        end

        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
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
          expose :address
        end
      end
    end
  end
end
