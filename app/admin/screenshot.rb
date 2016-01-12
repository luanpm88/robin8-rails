ActiveAdmin.register_page "Screenshot" do

  content do
    campaigns =[]
    kols = []
    sum = CampaignInvite.joins(:campaign, :kol).where("screenshot != ? AND img_status = ? AND (campaign_invites.status = ? OR campaign_invites.status = ?) AND (campaigns.actual_deadline_time is null or campaigns.actual_deadline_time > ?)", "", "pending", "approved", "finished", Time.now-1.days).count
    @campaign_invites = CampaignInvite.joins(:campaign, :kol).where("screenshot != ? AND img_status = ? AND (campaign_invites.status = ? OR campaign_invites.status = ?) AND (campaigns.actual_deadline_time is null or campaigns.actual_deadline_time > ?)", "", "pending", "approved", "finished", Time.now-1.days).limit(12)
    count = @campaign_invites.count
    count.times do |i|
      campaigns << @campaign_invites[i].campaign
      kols << @campaign_invites[i].kol
    end
    render 'show_screenshot', locals: { sum: sum, count: count, campaign_invites: @campaign_invites, campaigns: campaigns, kols: kols }
  end
end
