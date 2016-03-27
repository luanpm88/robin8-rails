class MarketingDashboard::CampaignsController < MarketingDashboard::BaseController
  def index
    @campaigns = Campaign.paginate(paginate_params)
  end
end
