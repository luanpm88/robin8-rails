class MarketingDashboard::PublicWechatAccountsController < MarketingDashboard::BaseController
  def index
    @q    = PublicWechatAccount.includes(:kol, :cities, :circles).ransack(params[:q])
    @public_wechat_accounts = @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def update
    @public_wechat_account = PublicWechatAccount.find params[:id]
    status = params['status']
    if params['status'] == "passed"
      @public_wechat_account.update_column(:profile_id, params[:profile_id])
      result = BigV::PublicWechatAccount.bind(@public_wechat_account.kol_id, params[:profile_id])
      if JSON(result)['result'] == "success"
        @public_wechat_account.update_column(:status, 1)
        @public_wechat_account.is_read.set 1
        @public_wechat_account.kol.update_column(:role_apply_status, 'passed')
      else
        flash[:notice] = JSON(result)['error_msg']
        return render json: { error:  JSON(result)['error_msg']}
      end
    elsif params['status'] == "rejected"
      @public_wechat_account.update_column(:status, -1)
      @public_wechat_account.update_column(:remark, params[:remark])
      @public_wechat_account.is_read.set -1
      @public_wechat_account.kol.update_column(:role_apply_status, 'rejected')
    end

    flash[:notice] = params['status'] == "passed" ? '申请通过' : "申请拒绝，请查看备注信息"
    return render json: { result: params['status'] }
  end

  def show
    @public_wechat_account = PublicWechatAccount.find params[:id]
    @circles = @public_wechat_account.circles
    @cities = @public_wechat_account.cities
  end

end
