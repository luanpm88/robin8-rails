module Campaigns
  module CampaignTargetHelper
    extend ActiveSupport::Concern
    included do
      has_many :campaign_targets
      has_one :influence_score_target, -> {where(:target_type => 'influence_score')}, class_name: "CampaignTarget"
      has_one :region_target, -> {where(:target_type => 'region')}, class_name: "CampaignTarget"
      has_one :tag_target, -> {where(:target_type => 'tags')}, class_name: "CampaignTarget"
      has_one :sns_platform_target, -> {where(:target_type => 'sns_platforms')}, class_name: "CampaignTarget"
      has_one :gender_target, -> {where(:target_type => 'gender')}, class_name: "CampaignTarget"
      has_one :age_target, -> {where(:target_type => 'age')}, class_name: "CampaignTarget"
      has_one :newbie_kol_target, -> {where(:target_type => [:newbie_kols])}, class_name: "CampaignTarget"
      has_many :manual_campaign_targets, -> {where(:target_type => CampaignTarget::TargetTypes.keys)}, class_name: "CampaignTarget"
      has_many :remove_campaign_targets, -> {where(:target_type => [:remove_campaigns])}, class_name: "CampaignTarget"
      has_many :remove_kol_targets, -> {where(:target_type => [:remove_kols])}, class_name: "CampaignTarget"
      has_many :add_kol_targets, -> {where(:target_type => [:add_kols])}, class_name: "CampaignTarget"
      has_many :specified_kol_targets, -> {where(:target_type => [:specified_kols])}, class_name: "CampaignTarget"
      has_many :social_account_targets, -> {where(:target_type => :social_accounts)}, class_name: "CampaignTarget"
      has_one :ios_platform_target, -> {where(:target_type => 'ios_platform')}, class_name: "CampaignTarget"
      has_one :android_platform_target, -> {where(:target_type => 'android_platform')}, class_name: "CampaignTarget"
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
      CampaignInvite.where(:campaign_id => campaign_ids).where(:status => ['approved', 'finished', 'settled']).map(&:kol_id)
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
        CampaignInvite.where("approved_at > '#{Campaign::ReceiveCampaignInterval.ago}'").collect{|t| t.kol_id}
      end

    end

    # 获取匹配kols
    def get_matching_kol_ids
      return [] if self.newbie_kol_target.present?

      # TODO big_v 正式上线后 可以把 active 去掉
      kols = Kol.active.personal_big_v

      kols = kols.where("`kols`.`app_version` >= '1.2.0'")    if self.is_recruit_type?

      self.campaign_targets.each do |target|
        if target.target_type == 'region'
          unless target.target_content == '全部' || target.target_content == '全部 全部'
            cities = target.target_content.split(',').collect { |name| City.where("name like '#{name}%'").first.name_en }
            kols = kols.where(:app_city => cities)
          end
        elsif target.target_type == 'tags'
          unless target.target_content == '全部'
            kols = kols.joins("INNER JOIN `kol_tags` ON `kols`.`id` = `kol_tags`.`kol_id`")
            kols = kols.where("`kol_tags`.`tag_id` IN (?)", target.get_tags)
          end
        elsif target.target_type == 'sns_platforms' and !self.is_recruit_type?
          unless target.target_content == '全部'
            kols = kols.joins("INNER JOIN `social_accounts` ON `kols`.`id` = `social_accounts`.`kol_id`")
            kols = kols.where("`social_accounts`.`provider` IN (?)", target.get_sns_platforms)
          end
        elsif target.target_type == 'age'
          unless target.target_content == '全部'
            min_age = target.target_content.split(',').map(&:to_i).first
            max_age = target.target_content.split(',').map(&:to_i).last
            kols = kols.where(age: Range.new(min_age, max_age))
          end
        elsif target.target_type == 'gender'
          unless target.target_content == '全部'
            kols = kols.where(gender: target.target_content.to_i)
          end
        elsif target.target_type == 'ios_platform'
          kols = kols.ios
        elsif target.target_type == 'android_platform'
          kols = kols.android
        #TODO 添加指定kols
        # elsif target.target_type == 'age'
        #   kols = kols.where("age > '#{target.contents}'")
        # elsif target.target_type == 'age'
        #   kols = kols.where("age > '#{target.contents}'")
        # elsif target.target_type == 'gender'
        #   kols = kols.where("gender = '#{target.contents}'")
        end
        #TODO 添加指定kols
      end

      kols.distinct.collect{|t| t.id} - get_unmatched_kol_ids rescue []
    end

    def get_append_kol_ids
      Kol.active.map(&:id) - self.get_matching_kol_ids - self.get_unmatched_kol_ids rescue []
    end

    def get_kol_ids
      if self.is_invite_type?
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
