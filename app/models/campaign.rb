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

  def get_avail_click
    status == 'executed' ? self.avail_click : self.redis_avail_click
  end

  def send_invites()
    ActiveRecord::Base.transaction do
      Kol.all.each do |kol|
        invite = CampaignInvite.new
        invite.status = ''
        invite.campaign_id = self.id
        invite.kol_id = kol.id
        uuid = Base64.encode64({:campaign_id => self.id, :kol_id=> kol.id}.to_json)
        invite.uuid = uuid
        invite.share_url = CampaignInvite.generate_share_url(uuid)
        invite.save!
      end
    end
  end

  def add_click(valid)
    self.redis_avail_click.increment  if valid
    self.redis_total_click.increment
    finish('fee_end') if self.redis_avail_click.value >= self.max_click
  end

  #finish_remark:  expired or fee_end
  def finish(finish_remark)
    if Rails.application.config.china_instance
      ActiveRecord::Base.transaction do
        update_info(finish_remark)
        update_invites
        settle_accounts
      end
    end
  end

  def update_info(finish_remark)
    self.avail_click = self.redis_avail_click.value
    self.status = 'executed'
    self.finish_remark = finish_remark
    self.save!
  end

  # 更新invite 状态和点击数
  def update_invites
    campaign_invites.each do |invite|
      invite.status = 'F'
      invite.avail_click = invite.redis_avail_click
      invite.save!
    end
  end

  # 结算
  def settle_accounts
    self.user.unfrozen(budget, 'campaign')
    self.user.income((budget - avail_click * per_click_budget) , 'campaign-remain', self )
    campaign = self
    self.campaign_invites.each do |invite|
      invite.kol.income(avail_click * campaign.per_click_budget, 'campaign', campaign, campaign.user)
    end
  end

  def create_job
    if Rails.application.config.china_instance
      if self.user.avail_amount > self.budget
        self.update_attribute(:max_click, self.budget / per_click_budget)
        self.user.frozen(budget, 'campaign', self)
        CampaignWorker.perform_at(self.start_time, self.id, 'start')
        CampaignWorker.perform_at(self.deadline,self.id, 'end')
      else
        Rails.logger.error('品牌商余额不足--campaign_id: #{self.id}')
      end
    end
  end

  def self.add_test_data
    if Rails.env.development?
      CampaignInvite.delete_all
      Transaction.delete_all
      CampaignShow.delete_all
      u = User.find 81
      Campaign.create(:user => u, :budget => 1, :per_click_budget => 0.2, :start_time => Time.now + 10.seconds, :deadline => Time.now + 10.minutes,
      :url => "http://www.baidu.com", :name => 'test')
    end
  end

end
