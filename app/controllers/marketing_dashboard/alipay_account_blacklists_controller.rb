class MarketingDashboard::AlipayAccountBlacklistsController < MarketingDashboard::BaseController
  def index
    authorize! :read, Withdraw
    @alipay_accounts = AlipayAccountBlacklist.all
    @q = @alipay_accounts.ransack(params[:q])
    @alipay_accounts = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def disban
    authorize! :update, Withdraw
    @alipay_account = AlipayAccountBlacklist.find(params[:id])
    @alipay_account.destroy
    redirect_to action: :index
  end
end
