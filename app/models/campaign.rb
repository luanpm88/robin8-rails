class Campaign < ActiveRecord::Base
  include Redis::Objects
  counter :redis_avail_click
  counter :redis_total_click

  belongs_to :user
  has_many :campaign_invites
  has_many :kols, through: :campaign_invites
  has_many :weibo_invites
  has_many :weibo, through: :weibo_invites
  has_many :articles
  has_many :kol_categories, :through => :kols

  has_many :campaign_categories
  has_many :iptc_categories, :through => :campaign_categories
  has_many :interested_campaigns
  belongs_to :release

  after_create :create_job

  # def self.get(id)
  #   Rails.cache.fetch("campaign-#{id}"){
  #     Campaign.where(:id => id).first
  #   }
  # end



  def add_click(valid)
    self.redis_avail_click.increment  if valid
    self.redis_total_click.increment
    finish('fee_end') if self.redis_avail_click.value >= self.max_click
  end

  #finish_remark:  expired or fee_end
  def finish(finish_remark)
    ActiveRecord::Base.transaction do
      update_info(finish_remark)
      update_invites
      settle_accounts
    end
  end

  def update_info(finish_remark)
    self.valid_click = self.redis_avail_click.value
    self.status = 'executed'
    self.finish_remark = finish_remark
    self.save!
  end

  def update_invites
    campaign_invites.each do |invite|
      invite.status = 'F'
      invite.avail_click = invite.redis_avail_click
      invite.save!
    end
  end

  def settle_accounts
    self.user.unfrozen(burget, 'campaign')
    self.user.income((burget - valid_click * per_click_burget) , 'campaign-remain', self )
    campaign = self
    self.campaign_invites.each do |invite|
      invite.kol.income(avail_click * campaign.per_click_burget, 'campaign', campaign, campaign.user)
    end
  end

  def create_job
    self.updat_attribute(:emax_click, self.budget / per_click_burget)
    self.user.frozen(credits, 'campaign', self)
    CampaignWorker.perform_at(self.start_time, self.id, 'start')
    CampaignWorker.perform_at(self.deadline,self.id, 'end')
  end

end
