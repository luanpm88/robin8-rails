module Campaigns
  module CampaignTargetHelper
    extend ActiveSupport::Concern
    included do
      has_many :campaign_targets
      has_one :influence_score_target, -> {where(:target_type => 'influence_score')}, class_name: "CampaignTarget"
      has_one :region_target, -> {where(:target_type => 'region')}, class_name: "CampaignTarget"
      has_one :profession_target, -> {where(:target_type => 'professions')}, class_name: "CampaignTarget"
      has_one :sns_platform_target, -> {where(:target_type => 'sns_platforms')}, class_name: "CampaignTarget"
      has_many :manual_campaign_targets, -> {where(:target_type => [:remove_campaigns, :remove_kols, :add_kols, :specified_kols])}, class_name: "CampaignTarget"
      has_many :remove_campaign_targets, -> {where(:target_type => [:remove_campaigns])}, class_name: "CampaignTarget"
      has_many :remove_kol_targets, -> {where(:target_type => [:remove_kols])}, class_name: "CampaignTarget"
      has_many :add_kol_targets, -> {where(:target_type => [:add_kols])}, class_name: "CampaignTarget"
      has_many :specified_kol_targets, -> {where(:target_type => [:specified_kols])}, class_name: "CampaignTarget"
      has_many :social_account_targets, -> {where(:target_type => :social_accounts)}, class_name: "CampaignTarget"
    end

    def get_unmatched_kol_ids
      # 获取 不匹配的kol_ids
      # (接过指定campaign 的kols + 指定去掉的kol + 黑名单中的kol + 今日结果三次 + 三小时内接过).uniq - 指定添加的kol
      (get_remove_kol_ids_of_campaign_by_target + get_remove_kol_ids_by_target + get_black_list_kols +
        today_receive_three_times_kol_ids + three_hours_had_receive_kol_ids).uniq - add_kols_by_targets
    end

    def get_remove_kol_ids_by_target
      get_ids_from_target_content self.remove_kol_targets.map(&:target_content)
    end


    def get_black_list_kols
      self.class.get_black_list_kols
    end

    def add_kols_by_targets
      get_ids_from_target_content self.add_kol_targets.map(&:target_content)
    end

    def get_remove_kol_ids_of_campaign_by_target
      campaign_ids = get_ids_from_target_content self.remove_campaign_targets.map(&:target_content)
      CampaignInvite.where(:campaign_id => campaign_ids).map(&:kol_id)
    end

    def today_receive_three_times_kol_ids
      self.class.today_receive_three_times_kol_ids
    end

    # 针对特邀活动，指定了特定的社交账号，通过社交账号来找到KOL
    def get_social_account_related_kol_ids
      return nil if self.social_account_targets.blank?

      account_ids = get_ids_from_target_content(self.social_account_targets.map(&:target_content))
      SocialAccount.where(id: account_ids).map(&:kol_id).presence
    end

    # 获取指定kols
    def get_specified_kol_ids
      return nil if self.specified_kol_targets.blank?
      get_ids_from_target_content self.specified_kol_targets.map(&:target_content)
    end

    def three_hours_had_receive_kol_ids
      if self.budget >= 500
        return []
      else
        CampaignInvite.where("approved_at > '#{3.hours.ago}'").collect{|t| t.kol_id}
      end

    end

    # 获取匹配kols
    def get_matching_kol_ids
      kols = nil
      self.campaign_targets.each do |target|
        if target.target_type == 'region'
          if self.is_recruit_type?
            if target.target_content == '全部' || target.target_content == '全部 全部'
              kols = Kol.active.ios.where("app_version >= '1.2.0'")
            else
              kols = Kol.active.ios.where(:app_city => target.get_citys).where("app_version >= '1.2.0'")
            end
          end
          #TODO 添加指定kols
        # elsif target.target_type == 'age'
        #   kols = kol.where("age > '#{target.contents}'")
        # elsif target.target_type == 'age'
        #   kols = kol.where("age > '#{target.contents}'")
        # elsif target.target_type == 'gender'
        #   kols = kol.where("gender = '#{target.contents}'")
        end
      end
      kols ||= Kol.active
      kols.collect{|t| t.id }  - get_unmatched_kol_ids   rescue []
    end

    def get_kol_ids
      if self.per_budget_type == "invite"
        get_social_account_related_kol_ids
      else
        (get_specified_kol_ids ||  get_matching_kol_ids)
      end
    end

    class_methods do
      def get_black_list_kols
        Kol.where("forbid_campaign_time > '#{Time.now}'").map(&:id)
      end

      def today_receive_three_times_kol_ids
        CampaignInvite.today_approved.group("kol_id").having("count(kol_id) >= 3").collect{|t| t.kol_id}
      end
    end


    private
    def get_ids_from_target_content contents
      contents.map do |content|
        content.gsub("，", ",").split(",").map(&:strip).map(&:to_i)
      end.flatten.uniq
    end
  end
end
