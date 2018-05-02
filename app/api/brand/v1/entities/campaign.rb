module Brand
  module V1
    module Entities
      class Campaign < Entities::Base

        expose :id, :name, :description, :short_description,
               :img_url, :status, :message, :url, :address, :budget,
               :per_budget_type, :per_action_budget, :hide_brand_name, :end_apply_check,
               :budget_editable, :pay_way, :need_pay_amount, :sub_type, :effect_score, :review_content, :evaluation_status,
               :example_screenshot_count, :enable_append_push

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

        expose :remain_budget

        expose :materials do |object, opts|
          if object.campaign_materials
            materials = []
            object.campaign_materials.each do |material|
              materials << {id: material.id, url_type: material.url_type, url: material.url}
            end
            materials.to_json
          end
        end

        expose :material_ids do |object, opts|
          if object.campaign_materials
            object.campaign_materials.pluck(:id)
          end
        end

        # TODO thoes lines should placed in CampaignTarget entity make code simple and beauty
        expose :age do |object, opts|
          target = object.age_target
          target.target_content if target
        end

        expose :gender do |object, opts|
          target = object.gender_target
          target.target_content if target
        end

        expose :region do |object, opts|
          target = object.region_target
          target.target_content.gsub(",", "/") if target
        end

        expose :influence_score do |object, opts|
          target = object.campaign_targets.find_by(target_type: "influence_score")
          target.target_content if target
        end

        expose :social_accounts do |object, opts|
          target = object.social_account_targets.first
          target.target_content.split(",").map(&:to_i) rescue []
        end

        expose :selected_social_accounts, using: Entities::SocialAccount do |object, opts|
          target = object.social_account_targets.first
          social_accounts = target.target_content.split(",").map(&:to_i) rescue []
          ::SocialAccount.where(id: social_accounts)
        end

        expose :tags do |object, opts|
          target = object.tag_target
          target.target_content.split(',') if target
        end

        expose :tag_labels do |object, opts|
          target = object.tag_target
          if target
            target.target_content.split(',').collect { |name| ::Tag.get_lable_by_name(name) }
          end
        end

        expose :sns_platforms do |object, opts|
          target = object.sns_platform_target
          target.target_content.split(",") if target
        end
        # ---------------------------------------------------

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

        expose :total_invite_kols_count do |object, opts| # 邀请活动: 总邀请人数
          object.campaign_invites.count if object.per_budget_type == "invite"
        end

        expose :total_agreed_invite_kols_count do |object, opts| #邀请活动: 接受活动的人数
          object.campaign_invites.verifying_or_approved.count if object.per_budget_type == "invite"
        end

        with_options(format_with: :iso_timestamp) do
          expose :created_at
          expose :updated_at
        end

      end
    end
  end
end
