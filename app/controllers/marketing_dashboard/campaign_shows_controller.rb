class MarketingDashboard::CampaignShowsController < MarketingDashboard::BaseController
  def index
    @campaign = Campaign.find_by params[:campaign_id]
    @campaign_shows = @campaign.campaign_shows.paginate(:page => 1, :per_page => 20)
  end
end
