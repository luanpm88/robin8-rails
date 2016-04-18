module Campaigns
  module CampaignTargetHelper
    extend ActiveSupport::Concern
    included do
      has_many :campaign_targets, -> {where(:target_type => [:age, :region, :gender])}
      has_many :manual_campaign_targets, -> {where(:target_type => [:remove_campaigns, :remove_kols, :add_kols])}, class_name: "CampaignTarget"
      has_many :remove_campaign_targets, -> {where(:target_type => [:remove_campaigns])}, class_name: "CampaignTarget"
      has_many :remove_kol_targets, -> {where(:target_type => [:remove_kols])}, class_name: "CampaignTarget"
      has_many :add_kol_targets, -> {where(:target_type => [:add_kols])}, class_name: "CampaignTarget"
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
      Kol.where("forbid_campaign_time > '#{Time.now}'").map(&:id)
    end

    def add_kols_by_targets
      get_ids_from_target_content self.add_kol_targets.map(&:target_content)
    end

    def get_remove_kol_ids_of_campaign_by_target
      campaign_ids = get_ids_from_target_content self.remove_campaign_targets.map(&:target_content)
      CampaignInvite.where(:campaign_id => campaign_ids).map(&:kol_id)
    end

    def today_receive_three_times_kol_ids
      CampaignInvite.today_approved.group("kol_id").having("count(kol_id) >= 3").collect{|t| t.kol_id}
    end

    private
    def get_ids_from_target_content contents
      contents.map do |content|
        content.gsub("，", ",").split(",").map(&:strip).map(&:to_i)
      end.flatten.uniq
    end
  end
end
