
class MarketingDashboard::EWallets::TransactionsController < MarketingDashboard::BaseController

  def index
    @campaign = Campaign.find params[:campaign_id]
    @transactons = EWallet::Transtion.where(resource: @campaign)
  end

  def withdraw
    @campaign = Campaign.find params[:campaign_id]
    @transacton = EWallet::Transtion.find params[:id]
    #调用接口
    txid = 'XXX'
    if txid.present?
      @transacton.txid = txid
      @transacton.status = "successful"
    else
      @transacton.status = "falied"
    end
    @transacton.save

    redirect_to marketing_dashboard_e_wallets_campaign_transactions_path(@campaign)
  end

end