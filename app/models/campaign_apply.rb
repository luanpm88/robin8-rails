class CampaignApply < ActiveRecord::Base
  # Status = ['appling', 'platform_passed', 'platform_rejected' 'brand_passed', 'brand_rejected']    其对应 campaign 的状态都是 approved,每个状态会关闭一些approved
  scope :applying, -> {where(:status => 'applying')}
  scope :platform_passed, -> {where(:status => 'platform_passed')}
  scope :brand_passed, -> {where(:status => 'brand_passed')}

  scope :brand_not_passed, -> {where("status != 'brand_passed'")}

  #kol_ids 审核通过的用户
  def self.platform_pass_kols(campaign_id, kol_ids = [])
    all_apply_ids = CampaignApply.applying.where(:campaign_id => campaign_id).collect{|t| t.kol_id }
    need_reject_kol_ids = all_apply_ids - kol_ids
    CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => need_reject_kol_ids).update_all(:status => 'platform_rejected')
    CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => need_reject_kol_ids).update_all(:status => 'rejected')
  end

  #kol_ids 审核通过的用户
  def self.brand_pass_kols(campaign_id, kol_ids = [])
    all_apply_ids = CampaignApply.platform_passed.where(:campaign_id => campaign_id).collect{|t| t.kol_id }
    need_reject_kol_ids = all_apply_ids - kol_ids
    CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => need_reject_kol_ids).update_all(:status => 'brand_rejected')
    CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => need_reject_kol_ids).update_all(:status => 'rejected')
  end

  def self.end_apply(campaign_id)
    #check again 避免没有审核一直停留在这个状态
    not_passed_kol_ids  =  CampaignApply.where(:campaign_id => campaign_id).brand_not_passed.collect{|t| t.kol_id}
    CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => not_passed_kol_ids).update_all(:status => 'brand_rejected')
    CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => not_passed_kol_ids).update_all(:status => 'rejected')

    # 对审核通过的invite 改状态 applying -> approved
    CampaignInvite.where(:campaign_id => campaign_id).where(:status => 'applying').update_all(:status => 'approved')
  end


end
