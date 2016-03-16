class CampaignTarget < ActiveRecord::Base
  belongs_to :campaign

  validates_presence_of :target_type, :target_content
  validates_inclusion_of :target_type, :in => %w(age region gender)
end
