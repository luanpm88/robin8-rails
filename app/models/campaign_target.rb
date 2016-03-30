class CampaignTarget < ActiveRecord::Base
  TargetTypes = {
    :remove_campaign => "去掉参与该活动的人",
  }
  attr_accessor :target_type_text

  belongs_to :campaign

  validates_presence_of :target_type, :target_content
  validates_inclusion_of :target_type, :in => %w(age region gender remove_campaign)
end
