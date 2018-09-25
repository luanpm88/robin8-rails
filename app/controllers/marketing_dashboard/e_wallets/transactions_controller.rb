class MarketingDashboard::EWallets::TransactionsController < MarketingDashboard::BaseController
  before_filter :get_campaign, only: [:index]

  def index
    @transtions = @campaign.e_wallet_transtions.includes(:kol).where(status: params[:status]).paginate(paginate_params)
  end

  def update_txid
    tr = EWallet::Transtion.find_by_id params[:tr_id]

    if tr && params[:tx_id]
      tr.update_attributes(status: 'successful', txid: params[:tx_id])
    else
      tr.update_attributes(status: 'failed') if tr
    end

    return render json: {result: 'success'}
  end

  def list
    kol = Kol.find params[:kol_id]
    @transtions = kol.e_wallet_transtions.paginate(paginate_params)
  end

  private

  def get_campaign
    @campaign = Campaign.find params[:campaign_id]
  end

end
