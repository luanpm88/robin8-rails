
class MarketingDashboard::EWallets::CampaignsController < MarketingDashboard::BaseController

  def index
  	@campaigns = Campaign.includes(:e_wallet_transtions).is_present_puts.order(created_at: :desc).paginate(paginate_params)
  end

end