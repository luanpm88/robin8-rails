class MarketingDashboard::WeiboAccountsController < MarketingDashboard::BaseController
  def index
    @q = WeiboAccount.includes(:kol, :cities, :circles).ransack(params[:q])
    @weibo_accounts= @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def update
    @weibo_account = WeiboAccount.find params[:id]
    status = params['status']
    if params['status'] == "passed"
      @weibo_account.update_column(:status, 1)
      @weibo_account.is_read.set 1
      @weibo_account.kol.update_column(:role_apply_status, 'passed')
    elsif params['status'] == "rejected"
      @weibo_account.update_column(:status, -1)
      @weibo_account.is_read.set -1
      @weibo_account.kol.update_column(:role_apply_status, 'rejected')
    end

    flash[:notice] = "修改成功"
    redirect_to :action => :index
  end

  def show
    @weibo_account = WeiboAccount.find params[:id]
    @circles = @weibo_account.circles
    @cities = @weibo_account.cities
  end
end
