ActiveAdmin.register_page "Screenshot" do

  content do
    campaigns =[]
    kols = []
    sum = CampaignInvite.joins(:campaign, :kol).where("screenshot != ? AND img_status = ? AND campaigns.status = ?", "", "pending", "executed" ).count
    @campaign_invites = CampaignInvite.joins(:campaign, :kol).where("screenshot != ? AND img_status = ? AND campaigns.status = ?", "", "pending", "executed" ).limit(12)
    count = @campaign_invites.count
    count.times do |i|
      campaigns << @campaign_invites[i].campaign
      kols << @campaign_invites[i].kol
    end
    render 'show_screenshot', locals: { sum: sum, count: count, campaign_invites: @campaign_invites, campaigns: campaigns, kols: kols }
  end
end
