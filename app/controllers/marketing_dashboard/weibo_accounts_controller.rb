class MarketingDashboard::WeiboAccountsController < MarketingDashboard::BaseController
  def index
    @q = WeiboAccount.includes(:kol, :cities, :circles).ransack(params[:q])
    @weibo_accounts= @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def update
    @weibo_account = WeiboAccount.find params[:id]
    status = params['status']
    if params['status'] == "passed"
      result = BigV::Weibo.bind(@weibo_account.kol_id, params[:profile_id])
      if JSON(result)['result'] == "success"
        @weibo_account.update_column(:status, 1)
        @weibo_account.update_column(:profile_id, params[:profile_id])
        @weibo_account.is_read.set 1
        @weibo_account.kol.update_column(:role_apply_status, 'passed')
      else
        @weibo_account.update_column(:profile_id, params[:profile_id])
        flash[:notice] = JSON(result)['error_msg']
        return render json: { error:  JSON(result)['error_msg']}
      end
    elsif params['status'] == "rejected"
      @weibo_account.update_column(:status, -1)
      @weibo_account.update_column(:remark, params[:remark])
      @weibo_account.is_read.set -1
      @weibo_account.kol.update_column(:role_apply_status, 'rejected')
    end

    flash[:notice] = params['status'] == "passed" ? '申请通过' : "申请拒绝，请查看备注信息"
    return render json: { result: params['status'] }
  end

  def show
    @weibo_account = WeiboAccount.find params[:id]
    @circles = @weibo_account.circles
    @cities = @weibo_account.cities
  end
end
