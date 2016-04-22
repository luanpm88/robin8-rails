class CampaignApply < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol
  has_one :campaign_invite

  scope :applying, -> {where(:status => 'applying')}
  scope :platform_passed, -> {where(:status => 'platform_passed')}
  scope :brand_passed, -> {where(:status => 'brand_passed')}
  scope :brand_not_passed, -> {where("status != 'brand_passed'")}

  validates_inclusion_of :status, :in => %w(applying platform_passed platform_rejected brand_passed brand_rejected)

  #kol_ids 审核通过的用户, 运营后台也实现了相同逻辑
  def self.platform_pass_kols(campaign_id, kol_ids = [], agree_reason = nil)
    CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => kol_ids).update_all(:status => 'platform_passed', :agree_reason => agree_reason)
  end

  #kol_ids 审核通过的用户
  def self.brand_pass_kols(campaign_id, kol_ids = [])
    CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => kol_ids).update_all(:status => 'brand_passed')
    CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => kol_ids).update_all(:status => 'approved')
  end

  def self.end_apply(campaign_id)
    #check again 避免没有审核一直停留在这个状态
    not_passed_kol_ids  =  CampaignApply.where(:campaign_id => campaign_id).brand_not_passed.collect{|t| t.kol_id}
    CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => not_passed_kol_ids).update_all(:status => 'brand_rejected')
    CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => not_passed_kol_ids).update_all(:status => 'rejected')
  end


end
