module Brand
  module V1
    module Entities
      class Campaign < Entities::Base

        expose :id, :name, :description, :short_description, :task_description,
               :img_url, :status, :message, :url, :address, :budget,
               :per_budget_type, :per_action_budget, :hide_brand_name, :end_apply_check,
               :budget_editable, :pay_way, :need_pay_amount

        expose :user, using: Entities::User

        expose :per_budget_collect_type do |object|
          if %w(cpa cpi).include? object.per_budget_type
            "cpa_cpi"
          else
            ""
          end
        end

        expose :recruit_person_count do |object, opts|
          object.recruit_person_count if object.per_budget_type == "recruit"
        end

        expose :recruit_start_time do |object, opts|
          object.recruit_start_time.strftime('%Y-%m-%d %H:%M') if object.recruit_start_time
        end

        expose :recruit_end_time do |object, opts|
          object.recruit_end_time.strftime('%Y-%m-%d %H:%M') if object.recruit_start_time
        end

        expose :deadline do |object, opts|
          object.deadline.strftime('%Y-%m-%d %H:%M')
        end

        expose :start_time do |object, opts|
          object.start_time.strftime('%Y-%m-%d %H:%M')
        end
        expose :avail_click do |object, opts|
          object.get_avail_click
        end
        expose :post_count

        expose :join_count

        expose :total_click do |object, opts|
          object.get_total_click
        end

        expose :fee_info do |object, opts|
          object.get_fee_info
        end
        expose :share_time do |object, opts|
          object.get_share_time
        end
        expose :take_budget
        expose :remain_budget
        # TODO thoes lines should placed in CampaignTarget entity make code simple and beauty
        expose :age do |object, opts|
          if object.per_budget_type != 'recruit'
            object.campaign_targets.present? ?  object.campaign_targets.find_by(target_type: "age").target_content : nil
          else
            nil
          end
        end
        expose :province do |object, opts|
          if object.per_budget_type != 'recruit'
            object.campaign_targets.present? ? object.campaign_targets.find_by(target_type: "region").target_content.split(" ").first : nil
          else
            nil
          end
        end
        expose :city do |object, opts|
          if object.per_budget_type != 'recruit'
            object.campaign_targets.present? ?  object.campaign_targets.find_by(target_type: "region").target_content.split(" ").last : nil
          else
            nil
          end
        end
        expose :gender do |object, opts|
          if object.per_budget_type != 'recruit'
            object.campaign_targets.present? ? object.campaign_targets.find_by(target_type: "gender").target_content : nil
          else
            nil
          end
        end

        expose :region do |object, opts|
          object.campaign_targets.where(target_type: :region).present? ? object.campaign_targets.find_by(target_type: "region").target_content : nil
        end
        expose :influence_score do |object, opts|
          object.campaign_targets.where(target_type: :influence_score).present? ? object.campaign_targets.find_by(target_type: 'influence_score').target_content : nil
        end

        expose :action_url do |object, opts|
          object.campaign_action_urls.present? ? object.campaign_action_urls.first.action_url : ""
        end

        expose :short_url do |object, opts|
          object.campaign_action_urls.present? ? object.campaign_action_urls.first.short_url : ""
        end

        expose :action_url_identifier do |object, opts|
          object.campaign_action_urls.present? ? object.campaign_action_urls.first.identifier : ""
        end

        expose :valid_applies_count do |object, opts|
          object.valid_applies.count if object.per_budget_type == 'recruit'
        end

        expose :brand_passed_count do |object, opts|
          object.brand_passed_applies.count if object.per_budget_type == 'recruit'
        end

        expose :take_budget do |object, opts|
          object.take_budget
        end

        expose :total_finished_kols do |object, opts|
          object.campaign_invites.where(status: "settled").count
        end

        expose :recruit_status do |object, opts|
            object.recruit_status if object.per_budget_type == 'recruit'
        end

        expose :invalid_reasons do |object, opts|
          object.invalid_reasons.gsub(/\n/, ' ') if object.invalid_reasons.present?
        end

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end

      end
    end
  end
end
