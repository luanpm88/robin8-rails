module Campaigns
  module CampaignTargetHelper
    extend ActiveSupport::Concern
    included do
      has_many :campaign_targets, -> {where(:target_type => [:age, :region, :gender])}
      has_many :manual_campaign_targets, -> {where(:target_type => [:remove_campaign])}, class_name: "CampaignTarget"
    end
  end
end