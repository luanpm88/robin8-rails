class MarketingDashboard::PublicWechatAccountsController < MarketingDashboard::BaseController
  def index
    @public_wechat_accounts = PublicWechatAccount.all
  end

  def update
    @public_wechat_account = PublicWechatAccount.find params[:id]
    status = params['status']
    if params['status'] == "passed"
      @public_wechat_account.update_column(:status, 1)
      @public_wechat_account.kol.update_column(:role_apply_status, 'passed')
    elsif params['status'] == "rejected"
      @public_wechat_account.update_column(:status, -1)
      @public_wechat_account.kol.update_column(:role_apply_status, 'rejected')
    end

    flash[:notice] = "修改成功"
    redirect_to :action => :index
  end

  def show
    @public_wechat_account = PublicWechatAccount.find params[:id]
    @circles = @public_wechat_account.circles
    @cities = @public_wechat_account.cities
  end

end
