class CampaignTarget < ActiveRecord::Base
  TargetTypes = {
    :remove_campaigns => "去掉参与指定活动的人(填写campaign_id)",
    :remove_kols      => "去掉指定的kols(填写kol_id)",
    :add_kols         => "添加指定的kols(填写(kol_id)",

  }
  attr_accessor :target_type_text

  belongs_to :campaign

  validates_presence_of :target_type, :target_content
  validates_inclusion_of :target_type, :in => %w(age region gender influence_score remove_campaigns remove_kols add_kols)

  before_validation :set_target_type_by_text

  def set_target_type_by_text
    if self.target_type.blank? and self.target_type_text.present?
      self.target_type = TargetTypes.select{|key, value| value ==  self.target_type_text}.keys.first
    end
  end

  def get_target_type_text
    TargetTypes[self.target_type.to_sym]
  end
end
