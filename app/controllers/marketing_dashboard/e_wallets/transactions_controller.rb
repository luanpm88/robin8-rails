
class MarketingDashboard::EWallets::TransactionsController < MarketingDashboard::BaseController

  def index
    @campaign = Campaign.find params[:campaign_id]
    @transactons = EWallet::Transtion.where(resource: @campaign)
  end

  def withdraw
    @campaign = Campaign.find params[:campaign_id]
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

end