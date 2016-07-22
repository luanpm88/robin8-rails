module Campaigns
  module CampaignTargetHelper
    extend ActiveSupport::Concern
    included do
      has_many :campaign_targets, -> {where(:target_type => [:age, :region, :gender, :influence_score])}
      has_one :influence_score_target, -> {where(:target_type => 'influence_score')}, class_name: "CampaignTarget"
      has_one :region_target, -> {where(:target_type => 'region')}, class_name: "CampaignTarget"
      has_many :manual_campaign_targets, -> {where(:target_type => [:remove_campaigns, :remove_kols, :add_kols, :specified_kols])}, class_name: "CampaignTarget"
      has_many :remove_campaign_targets, -> {where(:target_type => [:remove_campaigns])}, class_name: "CampaignTarget"
      has_many :remove_kol_targets, -> {where(:target_type => [:remove_kols])}, class_name: "CampaignTarget"
      has_many :add_kol_targets, -> {where(:target_type => [:add_kols])}, class_name: "CampaignTarget"
      has_many :specified_kol_targets, -> {where(:target_type => [:specified_kols])}, class_name: "CampaignTarget"
    end

    def get_unmatched_kol_ids
      # 获取 不匹配的kol_ids
      # (接过指定campaign 的kols + 指定去掉的kol + 黑名单中的kol).uniq - 指定添加的kol
      (get_remove_kol_ids_of_campaign_by_target + get_remove_kol_ids_by_target + get_black_list_kols +  today_receive_three_times_kol_ids).uniq - add_kols_by_targets
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

    # 获取指定kols
    def get_specified_kol_ids
      return nil if self.specified_kol_targets.blank?
      get_ids_from_target_content self.specified_kol_targets.map(&:target_content)
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
      get_specified_kol_ids ||  get_matching_kol_ids
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
