module Open
  module V1
    module Entities
      module Campaign
        class CampaignList < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }

          expose :id, :status, :budget, :per_action_budget
          expose :url, :poster_url, :name

          expose :tags do |object|
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

          expose :invalid_reasons
          expose :budget_stats_by_day
        end

        class CampaignDetail < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :status, :url, :per_action_budget, :budget, :activity_id
          expose :name, :description
          expose :take_budget, :share_times

          expose :poster_url do |object|
            object.img_url
          end

          expose :screenshot_url do |object|
            object.example_screenshot
          end

          with_options(format_with: :iso_timestamp) do
            expose :deadline
            expose :start_time
          end

          expose :invalid_reasons

          expose :total_click do |object|
            object.get_total_click
          end

          expose :avail_click do |object|
            object.get_avail_click
          end

          expose :tags do |object|
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
          expose :status  do |invite|
            invite.status
          end
          expose :avatar_url  do |invite|
            invite.kol.avatar_url
          end
          expose :kol_name    do |invite|
            invite.kol.safe_name
          end
          expose :screenshot_url do |invite|
            invite.screenshot
          end
          expose :avail_click do |invite|
            invite.get_avail_click
          end
          expose :earn_money do |invite|
            invite.earn_money(true)
          end
          expose :total_click do |invite|
            invite.get_total_click
          end
        end
      end
    end
  end
end
