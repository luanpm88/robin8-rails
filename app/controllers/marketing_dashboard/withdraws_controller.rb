class MarketingDashboard::WithdrawsController < MarketingDashboard::BaseController
  before_action :set_withdraw, only: [:check, :agree, :reject, :permanent_frozen, :permanent_frozen_alipay, :confiscate]

  def index
    authorize! :read, Withdraw
    @withdraws = Withdraw.of_kols
    formated_response "全部"
  end

  def pending
    authorize! :read, Withdraw
    @withdraws = Withdraw.of_kols.where(status: 'pending')

    formated_response "待审核的"
  end

  def checked
    authorize! :read, Withdraw
    @withdraws = Withdraw.of_kols.checked

    formated_response "已审核通过待付款的"
  end

  def agreed
    authorize! :read, Withdraw
    @withdraws = Withdraw.of_kols.where(status: 'paid')

    formated_response "已付款的"
  end

  def rejected
    authorize! :read, Withdraw
    @withdraws = Withdraw.of_kols.where(status: 'rejected')

    formated_response "已拒绝的"
  end

  def permanent_prohibited
    authorize! :read, Withdraw
    @withdraws = Withdraw.of_kols.where(status: 'permanent_frozen')

    formated_response "永久冻结的"
  end

  def check
    authorize! :update, Withdraw
    if @withdraw.kol.frozen_amount.to_f >= @withdraw.credits.to_f
      @withdraw.update_attributes(:status => 'checked')

      respond_to do |format|
        format.html { redirect_to :back, notice: '审核通过, 已进入待付款列表' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: '此kol账户余额不小于当前提现金额，未能通过审核!' }
      end
    end
  end

  def agree
    authorize! :update, Withdraw
    if @withdraw.kol.frozen_amount.to_f >= @withdraw.credits.to_f
      @withdraw.update_attributes(:status => 'paid')

      respond_to do |format|
        format.html { redirect_to :back, notice: '同意提现成功' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: '此kol账户余额不小于当前提现金额，提现失败!' }
      end
    end
  end

  def reject
    authorize! :update, Withdraw
    @withdraw.update_attributes(:status => 'rejected', :reject_reason => params[:reject_reason])
    flash[:notice] = "拒绝成功, 已移到拒绝列表"
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Reject sucessfully!' }
      format.json { head :no_content }
    end
  end

  # This button (rendered in views/marketing_dashboard/withdraws/index.html.erb)
  # allows the admin to confiscate the money from a particular when they reuqest a withdrawal, possibly due to cheating of clicks or inivitation.

  def confiscate
    authorize! :update, Withdraw
    @withdraw.update_attributes(:status => 'confiscated', :reject_reason => params[:confiscate_reason])
    #flash[:notice] = "拒绝成功, 已移到拒绝列表"
    flash[:notice] = "已经没收了该提现。"
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Confiscate sucessfully!' }
      format.json { head :no_content }
    end
  end

  def permanent_frozen
    authorize! :update, Withdraw
    @withdraw.update_attributes(:status => 'permanent_frozen', :reject_reason => params[:reject_reason])
    flash[:notice] = "永久拒绝成功, 已移到拒绝列表"
    respond_to do |format|
      format.html { redirect_to :back, notice: 'permanent frozen sucessfully!' }
      format.json { head :no_content }
    end
  end

  def permanent_frozen_alipay
    authorize! :update, Withdraw
    if AlipayAccountBlacklist.where(account: @withdraw.alipay_no).present?
      redirect_to :back, notice: '此账号已被拉黑!'
    else
      AlipayAccountBlacklist.create!(account: @withdraw.alipay_no, withdraw_id: @withdraw.id)
      flash[:notice] = "冻结支付宝帐号成功, 已移到拒绝列表"
      @withdraw.update_attributes(status: :alipay_frozen, :reject_reason => params[:reject_reason])
      redirect_to :back, notice: '冻结支付宝帐号成功!'
    end
  end

  def batch_handle
    authorize! :update, Withdraw
    @withdraws = Withdraw.where(:id => params[:batch_ids].split(","))
    if @withdraws.all?{|t| t.status == 'pending'} or @withdraws.all?{|t| t.status == 'checked'}
      if params[:handle_action] == 'batch_check'
        @withdraws.each do |withdraw|
          withdraw.update_attributes(:status => "checked") if withdraw.kol.frozen_amount.to_f >= withdraw.credits.to_f
        end
      elsif params[:handle_action] == 'batch_agree'
        @withdraws.each do |withdraw|
          withdraw.update_attributes(:status => 'paid') if withdraw.kol.frozen_amount.to_f >= withdraw.credits.to_f
        end
      elsif params[:handle_action] == 'batch_reject'
        @withdraws.each do |withdraw|
          withdraw.update_attributes(:status => 'rejected', reject_reason: params[:reject_reason])
        end
      end
      render :json => {:status => 'ok', :message => '操作成功'}
    else
      render :json => {:status => 'error', :message => '你选择中含已审核的'}
    end
  end

  # def batch_reject
  #   @withdraws = Withdraw.where(:batch_withdraw_id => params[:batch_withdraw_id])
  #   if @withdraws.all?{|t| t.status == 'pending' }
  #     @withdraws.each do |withdraw|
  #       withdraw.update_attributes(:status => 'rejected')
  #     end
  #     flash[:notice] = '批量拒绝成功'
  #     redirect_to :aciton => 'index'
  #   else
  #     flash[:notice] = '你选择中含已审核的'
  #     redirect_to :aciton => 'index'
  #   end
  # end

  private
  def set_withdraw
    @withdraw = Withdraw.find params[:withdraw_id]
  end

  def formated_response(name)
    @q = @withdraws.ransack(params[:q])
    @withdraws = @q.result.order('created_at DESC').includes(:kol)

    respond_to do |format|
      format.html do
        @withdraws = @withdraws.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"#{name}提现记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end
end
