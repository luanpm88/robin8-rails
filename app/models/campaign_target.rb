class CampaignTarget < ActiveRecord::Base
  # target_type: 
  # remove_campaign 表示 去掉 接受这个campaign 的kol 列表
  # 
  belongs_to :campaign

  validates_presence_of :target_type, :target_content
  validates_inclusion_of :target_type, :in => %w(age region gender remove_campaign)
end
