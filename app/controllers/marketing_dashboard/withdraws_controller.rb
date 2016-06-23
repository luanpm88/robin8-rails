class MarketingDashboard::WithdrawsController < MarketingDashboard::BaseController
  before_action :set_withdraw, only: [:agree, :reject]

  def index
    @withdraws = Withdraw.all.order('created_at DESC').paginate(paginate_params)
  end

  def pending
    @withdraws = Withdraw.all.where(status: 'pending').order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def agreed
    @withdraws = Withdraw.all.where(status: 'paid').order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def rejected
    @withdraws = Withdraw.all.where(status: 'rejected').order('created_at DESC').paginate(paginate_params)

    render 'index'
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

  private
  def set_withdraw
    @withdraw = Withdraw.find params[:withdraw_id]
  end
end
