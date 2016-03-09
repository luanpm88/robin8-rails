ActiveAdmin.register_page "Screenshot" do

  content do
    campaigns =[]
    kols = []
    # TODO check timeline
    timeline = Rails.env.production? ? 4.days : 4.days
    campaign_invites = CampaignInvite.joins(:campaign, :kol).where("screenshot != ? AND img_status = ? AND (campaign_invites.status = ? OR campaign_invites.status = ?) AND campaigns.deadline > ?", "", "pending", "approved", "finished", Time.now-timeline)
    sum = campaign_invites.count
    @campaign_invites = campaign_invites.limit(12)
    count = @campaign_invites.count
    count.times do |i|
      campaigns << @campaign_invites[i].campaign
      kols << @campaign_invites[i].kol
    end
    render 'show_screenshot', locals: { sum: sum, count: count, campaign_invites: @campaign_invites, campaigns: campaigns, kols: kols }
  end
end
