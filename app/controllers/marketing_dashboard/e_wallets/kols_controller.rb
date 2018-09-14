class MarketingDashboard::EWallets::KolsController < MarketingDashboard::BaseController

  def index
    @e_wallet_accounts = EWallet::Account.includes(:kol).order(created_at: :desc).paginate(paginate_params)
  end

end
