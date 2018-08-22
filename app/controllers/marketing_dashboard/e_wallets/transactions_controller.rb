
class MarketingDashboard::EWallets::TransactionsController < MarketingDashboard::BaseController

  def index
    @campaign = Campaign.find params[:campaign_id]
    @transactons = EWallet::Transtion.where(resource: @campaign)
  end

  def withdraw
    @campaign = Campaign.find params[:campaign_id]
    @password = params[:password]
    token = "token"
    
    @campaign.e_wallet_transtions.pending.each do |transtion|
      signature= "signature"
      txid = PMES.transaction(token, public_key, transtion.amount, signature)
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