class MarketingDashboard::WithdrawsController < MarketingDashboard::BaseController
  before_action :set_withdraw, only: [:agree, :reject]

  def index
    @withdraws = Withdraw.all.order('created_at DESC').includes(:kol)

    formated_response "全部"
  end

  def search
    search_by = params[:search_key]
    kol = Kol.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params).first
    if kol
      @withdraws = Withdraw.where(:kol_id => kol.id).order('created_at DESC').includes(:kol)
    end
    formated_response "全部"
  end

  def pending
    @withdraws = Withdraw.all.where(status: 'pending').order('created_at DESC')

    formated_response "待处理的"
  end

  def agreed
    @withdraws = Withdraw.all.where(status: 'paid').order('created_at DESC')

    formated_response "通过的"
  end

  def rejected
    @withdraws = Withdraw.all.where(status: 'rejected').order('created_at DESC')

    formated_response "拒绝的"
  end

  def agree
    if @withdraw.kol.avail_amount.to_f > params[:credits].to_f
      @withdraw.update_attributes(:status => 'paid')

      respond_to do |format|
        format.html { redirect_to :back, notice: 'Deal withdraw successfully!' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: 'No enouth amount!' }
      end
    end
  end

  def reject
    @withdraw.update_attributes(:status => 'rejected')

    respond_to do |format|
      format.html { redirect_to :back, notice: 'Reject sucessfully!' }
      format.json { head :no_content }
    end
  end

  def batch_handle
    @withdraws = Withdraw.where(:id => params[:batch_ids].split(","))
    if @withdraws.all?{|t| t.status == 'pending' }
      if params[:handle_action] == 'batch_agree'
        @withdraws.each do |withdraw|
          withdraw.update_attributes(:status => 'paid') if withdraw.kol.frozen_amount.to_f > withdraw.credits.to_f
        end
      elsif params[:handle_action] == 'batch_reject'
        @withdraws.each do |withdraw|
          withdraw.update_attributes(:status => 'rejected')
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
    respond_to do |format|
      format.html do
        @withdraws = @withdraws.paginate(paginate_params) unless @withdraw
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
