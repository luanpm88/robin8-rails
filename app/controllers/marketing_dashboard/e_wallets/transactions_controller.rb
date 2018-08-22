class MarketingDashboard::EWallets::TransactionsController < MarketingDashboard::BaseController
  before_filter :get_campaign

  def index
    @transactons = @campaign.e_wallet_transtions.includes(:kol).paginate(paginate_params)
  end

  def withdraw
    @campaign.e_wallet_transtions.pending.each do |transtion|
      txid = 'XXX' #调用接口获取txid
      if txid.present?
        transtion.txid = txid
        transtion.status = "successful"
      else
        transtion.status = "falied"
      end
      transtion.save
    end
    redirect_to marketing_dashboard_e_wallets_campaign_transactions_path(@campaign)
  end

  private

  def get_campaign
    @campaign = Campaign.find params[:campaign_id]
  end

end