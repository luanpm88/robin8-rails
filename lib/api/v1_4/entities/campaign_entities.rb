module API
  module V1_4
    module Entities
      module CampaignEntities
        class CampaignStatsEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget, :remark, :sub_type, :need_pay_amount
          expose :cpi_example_screenshot do |campaign|
            campaign.example_screenshot
          end
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
            expose :cal_settle_time do |campaign|
              (campaign.cal_settle_time campaign.actual_deadline_time).strftime("%Y-%m-%d %H:%M:%S")
            end
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
            campaign.get_stats_for_app
          end

          expose :tags do |object|
            target = object.tag_target
            target.target_content.split(',') if target
          end

          expose :tag_labels do |object|
            target = object.tag_target
            if target
              target.target_content.split(',').collect { |name| ::Tag.get_lable_by_name(name) }.join(',')
            end
          end

          expose :region do |object|
            target = object.region_target
            target.target_content if target
          end

          expose :gender do |object|
            target = object.gender_target
            target.target_content if target
          end

          expose :age do |object|
            target = object.age_target
            target.target_content if target
          end

          expose :used_credits do |object|
            object.credit_amount
          end

        end

        class CampaignAlipayEntity < Grape::Entity
          expose :id, :status, :need_pay_amount
          expose :alipay_url do |campaign|
            campaign.generate_alipay_campaign_order
          end
        end

        class CampaignListEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :need_pay_amount, :status, :img_url, :name, :budget, :per_budget_type, :per_action_budget, :sub_type
          expose :tag_labels do |object|
            target = object.tag_target
            if target
              target.target_content.split(',').collect { |name| ::Tag.get_lable_by_name(name) }.join(',')
            end
          end

          expose :region do |object|
            target = object.region_target
            target.target_content if target
          end

          expose :gender do |object|
            target = object.gender_target
            target.target_content if target
          end

          expose :age do |object|
            target = object.age_target
            target.target_content if target
          end

          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
          expose :evaluation_status
          expose :effect_score
          expose :review_content
          expose :used_credits do |object|
            object.credit_amount
          end
        end

        class CampaignPayEntity < Grape::Entity
          expose :id, :need_pay_amount, :status
          expose :brand_amount do |campaign|
            campaign.user.avail_amount.to_f
          end

          expose :alipay_url do |campaign|
            campaign.generate_alipay_campaign_order
          end
        end

        class CampaignBalancePayEntity < Grape::Entity
          expose :id, :need_pay_amount, :status
        end

        class CreateCampaignEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget, :sub_type
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
        end

        class UnpayShowEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget, :need_pay_amount, :sub_type
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
        end

        class DetailEntity < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url, :img_url, :per_budget_type, :per_action_budget, :budget, :need_pay_amount, :voucher_amount, :used_voucher, :budget_editable, :sub_type
          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end
          expose :invalid_reasons do |campaign|
            if campaign.invalid_reasons.present?
              campaign.invalid_reasons.split("\n")
            else
              []
            end
          end

          expose :tag_labels do |object|
            target = object.tag_target
            if target
              target.target_content.split(',').collect { |name| ::Tag.get_lable_by_name(name) }.join(',')
            end
          end

          expose :region do |object|
            target = object.region_target
            target.target_content if target
          end

          expose :gender do |object|
            target = object.gender_target
            target.target_content if target
          end

          expose :age do |object|
            target = object.age_target
            target.target_content if target
          end

          expose :used_credits do |object|
            object.credit_amount
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
