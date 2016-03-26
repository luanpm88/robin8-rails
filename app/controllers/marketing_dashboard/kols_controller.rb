class MarketingDashboard::KolsController < MarketingDashboard::BaseController
  def index
    @campaign = Campaign.find_by params[:campaign_id]
    @kols = @campaign.kols.paginate(:page => 1, :per_page => 20)
  end
end
