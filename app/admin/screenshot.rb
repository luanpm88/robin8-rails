ActiveAdmin.register_page "Screenshot" do

  content do
    campaigns =[]
    kols = []
    timeline = Campaign::SettleWaitTimeForBrand
    sum = CampaignInvite.joins(:campaign, :kol).where("screenshot != ? AND img_status = ? AND (campaign_invites.status = ? OR campaign_invites.status = ?) AND campaigns.deadline > ?", "", "pending", "approved", "finished", Time.now-timeline).count
    @campaign_invites = CampaignInvite.joins(:campaign, :kol).where.not(:screenshot => "").where(:img_status => :pending).where(:status => ["approved", "finished"]).where("campaigns.deadline > ?", Time.now-timeline).page(params[:page] || 1).per_page(15)
    count = @campaign_invites.length
    count.times do |i|
      campaigns << @campaign_invites[i].campaign
      kols << @campaign_invites[i].kol
    end
    render 'show_screenshot', locals: { sum: sum, count: count, campaign_invites: @campaign_invites, campaigns: campaigns, kols: kols }
  end
end
