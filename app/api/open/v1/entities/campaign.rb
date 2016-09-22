module Open
  module V1
    module Entities
      module Campaign
        class CampaignList < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }

          expose :id, :status, :img_url, :name, :budget, :per_budget_type, :per_action_budget

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
        end

        class CampaignDetail < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :name, :description, :status, :url
          expose :per_budget_type, :per_action_budget, :budget, :remark
          expose :take_budget, :share_times

          expose :poster_url do |object|
            object.img_url
          end

          expose :screenshot_url do |object|
            object.cpi_example_screenshot
          end

          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
            expose :cal_settle_time do |object|
              (object.cal_settle_time object.actual_deadline_time).strftime("%Y-%m-%d %H:%M:%S")
            end
          end

          expose :invalid_reasons do |object|
            if object.invalid_reasons.present?
              object.invalid_reasons.split("\n")
            else
              []
            end
          end

          expose :avail_click do |object|
            object.get_avail_click
          end

          expose :total_click do |object|
            object.get_total_click
          end

          # expose :stats_data do |object|
          #   object.get_stats_for_app
          # end

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
        end

        class CampaignInviteList < Grape::Entity
          expose :kol_id
          expose :avatar_url  do |invite|
            invite.kol.avatar_url
          end
          expose :kol_name    do |invite|
            invite.kol.safe_name
          end
          expose :avail_click do |invite|
            invite.get_avail_click
          end
          expose :total_click do |invite|
            invite.get_total_click
          end
        end
      end
    end
  end
end