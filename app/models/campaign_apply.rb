class CampaignApply < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :kol
  has_one :campaign_invite
  has_many :images, :as => :referable

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
  # def self.brand_pass_kols(campaign_id, kol_ids = [])
  #   CampaignApply.where(:campaign_id => campaign_id).where(:kol_id => kol_ids).update_all(:status => 'brand_passed')
  # end

  def brand_pass_kol
    raise '超出最大招募人数' if CampaignApply.where(:campaign_id => self.campaign_id).brand_passed.count >= self.campaign.max_action
    self.update_column(:status, 'brand_passed')
  end

  def brand_reject_kol
    self.update_column(:status, 'platform_passed')
  end

  #结束审核
  def self.end_apply_check(campaign_id)
    campaign = Campaign.find campaign_id
    return if  campaign.end_apply_check == true
    ActiveRecord::Base.transaction do
      return if campaign.blank?
      campaign.update_columns({:end_apply_check => true, :end_apply_time => Time.now})
      #审核通过的
      brand_passed_kol_ids = CampaignApply.brand_passed.where(:campaign_id => campaign_id).collect{|t| t.kol_id}
      CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => brand_passed_kol_ids).update_all(:status => 'approved', :approved_at => Time.now)
      #剩余的拒绝掉
      CampaignApply.brand_not_passed.where(:campaign_id => campaign_id).update_all(:status => 'brand_rejected')
      rejected_kol_ids =  CampaignApply.brand_not_passed.where(:campaign_id => campaign_id).collect{|t| t.kol_id}
      CampaignInvite.where(:campaign_id => campaign_id).where(:kol_id => rejected_kol_ids).update_all(:status => 'rejected')
      campaign.push_start_notify
    end
  end

end
