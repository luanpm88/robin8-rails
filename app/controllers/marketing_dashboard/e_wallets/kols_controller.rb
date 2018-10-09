class MarketingDashboard::EWallets::KolsController < MarketingDashboard::BaseController

  def index
    @e_wallet_accounts = EWallet::Account.joins(:kol).order(created_at: :desc).paginate(paginate_params)
  end

  def transactions
    kol = Kol.find params[:id]
    @transtions = kol.e_wallet_transtions.paginate(paginate_params)
  end

end
