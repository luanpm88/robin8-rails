
class MarketingDashboard::EWallets::CampaignsController < MarketingDashboard::BaseController

  def index
  	@campaigns = Campaign.all.realable.is_present_puts.paginate(paginate_params)
  end

end