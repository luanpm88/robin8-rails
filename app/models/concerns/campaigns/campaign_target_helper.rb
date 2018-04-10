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
      has_many :admintag_targets, -> {where(:target_type => 'admintags')}, class_name: "CampaignTarget"
      has_many :td_promo_targets, -> {where(:target_type => 'td_promo')}, class_name: "CampaignTarget"
      has_many :remove_td_promo_targets, -> {where(:target_type => 'remove_td_promo')}, class_name: "CampaignTarget"
      has_many :cell_phones_targets, -> {where(:target_type => 'cell_phones')}, class_name: "CampaignTarget"
    end

    def get_unmatched_kols(kols)
      kols = kols.where.not(id: get_unmatched_kol_ids)
    end

    # 获取 不匹配的kol_ids
    def get_unmatched_kol_ids
      # (接过指定campaign 的kols +
      #  指定去掉的kol +
      #  黑名单中的kol +
      #  三小时内接过).uniq -
      #  指定添加的kol

      (get_remove_kol_ids_of_campaign_by_target +
       get_remove_kol_ids_by_target +
       get_black_list_kols +
       # three_hours_had_receive_kol_ids +
        get_approved_kol_ids
      ).uniq -
       add_kols_by_targets
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

    def get_approved_kol_ids
      self.campaign_invites.map(&:kol_id)
    end

    def get_remove_kol_ids_of_campaign_by_target
      campaign_ids = get_ids_from_target_content self.remove_campaign_targets.map(&:target_content)
      CampaignInvite.where(:campaign_id => campaign_ids).where(:status => ['approved', 'finished', 'settled']).map(&:kol_id)
    end

    # 针对特邀活动，指定了特定的社交账号，通过社交账号来找到KOL
    def get_social_account_related_kol_ids
      return nil if self.social_account_targets.blank?

      account_ids = get_ids_from_target_content(self.social_account_targets.map(&:target_content))
      SocialAccount.where(id: account_ids).map(&:kol_id).presence
    end

    #这个条件过滤出来的人 根据时候可能会变动，除去
    def three_hours_had_receive_kol_ids
      if self.budget >= 500
        return []
      else
        CampaignInvite.where("approved_at > '#{Campaign::ReceiveCampaignInterval.ago}'").collect{|t| t.kol_id}
      end
    end

    def get_platform_kols
      # modified from: Kol.active
      kols = Kol.campaign_message_suitable

      android_app_version =  self.android_platform_target.target_content  rescue nil || '1.0.0'
      ios_app_version =  self.ios_platform_target.target_content rescue nil || '1.0.0'
      if self.ios_platform_target.present? && self.android_platform_target.present?
        kols = kols.where("(app_platform = 'IOS' and app_version >= '#{ios_app_version}') or (app_platform = 'Android' and app_version >= '#{android_app_version}')")
      elsif self.ios_platform_target.present?
        kols = kols.ios.where("app_version >= '#{ios_app_version}'")
      elsif self.android_platform_target.present?
        kols = kols.android.where("app_version >= '#{android_app_version}'")
      end
      kols
    end

    def get_matching_kols(kols = nil, target_types = nil)
      kols ||= Kol.active

      targets = self.campaign_targets
      targets = targets.where(target_type: target_types) unless target_types.nil?
      targets.each do |target|
        next if target.target_type == 'sns_platforms' and self.is_recruit_type?

        kols = target.filter(kols)
      end

      kols.distinct
    end

    # 获取匹配kols
    # Notice : 把不匹配的移开,不在该方法计算
    def get_matching_kol_ids(kols = nil, target_types = nil)
      kols = get_matching_kols(kols, target_types)

      kols.select("id").map(&:id)
    end

    def get_remaining_kol_ids(target_types)
      return [] if self.is_invite_type? ||
         self.specified_kol_targets.present? ||
         self.newbie_kol_target.present?

      kols = get_platform_kols
      kols = get_matching_kols(kols, target_types)
      kols = get_unmatched_kols(kols)
      kol_ids = kols.select("id").map(&:id) rescue []

      records = CampaignPushRecord.where(campaign_id: self.id, filter_type: 'match')
      pushed_kol_ids   = records.inject([]) {|s, r| s += r.kol_ids.split(",").map(&:to_i) rescue [] }.uniq
      approved_kol_ids = CampaignInvite.where(campaign_id: self.id).map(&:kol_id)

      kol_ids = kol_ids - pushed_kol_ids - approved_kol_ids
    end

    #TODO imporve this
    def get_kol_ids(record = false, kol_ids = nil , push = false)
         #如果指定了kol_is 记录后直接返回
      if kol_ids.present?
        CampaignPushRecord.create(campaign_id: self.id, kol_ids: kol_ids.join(","), push_type: 'normal', filter_type: 'manual_special', filter_reason: 'manual_special')  if record
        return kol_ids
      end
      if self.is_invite_type?                        #特邀活动
        kol_ids  = get_social_account_related_kol_ids
        kols = Kol.where(id: kol_ids)
        CampaignPushRecord.create(campaign_id: self.id, kol_ids: kol_ids.join(","), push_type: 'normal', filter_type: 'match', filter_reason: 'invite')  if record
      elsif self.specified_kol_targets.present?       #指定任务
        kol_ids = get_ids_from_target_content self.specified_kol_targets.map(&:target_content)
        kols = Kol.where(id: kol_ids)
        CampaignPushRecord.create(campaign_id: self.id, kol_ids: kol_ids.join(","), push_type: 'normal', filter_type: 'match', filter_reason: 'specified_kol')  if record
      elsif self.newbie_kol_target.present?          #新手活动
        CampaignPushRecord.create(campaign_id: self.id, kol_ids: "", push_type: "newbie_kol", filter_type: 'match', filter_reason: 'newbie_kol')                    if record
        kol_ids = []
        kols = nil
      else
        kols = get_platform_kols
        kols = get_matching_kols(kols)
        kols = get_unmatched_kols(kols)
        kol_ids = kols.select(:id).map(&:id) rescue []
        # if push
        #   kol_device_token = kols.select(:device_token).map(&:device_token).uniq rescue []
        #   kol_device_token.each {|t| self.push_device_tokens << t} 
        # end
        CampaignPushRecord.create(campaign_id: self.id, kol_ids: kol_ids.join(","), push_type: 'normal', filter_type: 'match', filter_reason: 'match')          if record
        CampaignPushRecord.create(campaign_id: self.id, kol_ids: get_unmatched_kol_ids.join(","), push_type: 'normal', filter_type: 'unmatch', filter_reason: 'unmatch')   if record
      end
      if push
        kol_device_token = kols.select(:device_token).map(&:device_token).uniq rescue []
        kol_device_token.each {|t| self.push_device_tokens << t}  if kol_device_token.present?
      end
      if record
        Rails.logger.campaign_sidekiq.info "----cid:#{self.id}----kol_ids:#{kol_ids.inspect}"
        kols
      else
        kol_ids
      end
    end

    class_methods do
      def get_black_list_kols
        Kol.where("forbid_campaign_time > '#{Time.now}'").map(&:id)
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
