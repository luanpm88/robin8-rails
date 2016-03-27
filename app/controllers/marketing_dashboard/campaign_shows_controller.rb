class MarketingDashboard::CampaignShowsController < MarketingDashboard::BaseController
  def index
    @campaign = Campaign.find_by params[:campaign_id]
    @campaign_shows = @campaign.campaign_shows.paginate(paginate_params)
  end
end
