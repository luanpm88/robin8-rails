class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  before_action :set_user, only: [:recharge, :withdraw]

  def index
    authorize! :read, User

    @users = User.all

    if !params[:q] or params[:q][:is_active_eq].blank?
      params[:q] = { is_active_eq: true }
    end

    @users = @users.order('created_at DESC')

    respond_to do |format|
      format.html do
        @q = @users.ransack(params[:q])
        @users = @q.result.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        @users = @users.is_live

        if params[:filter] == "no_campaign"
          @users = @users.joins("LEFT OUTER JOIN campaigns ON campaigns.user_id = users.id").where("campaigns.user_id IS NULL")
          # @users = @users.includes(:campaigns).where(campaigns: { id: nil })
        elsif params[:filter] == "campagin_created"
          @users = @users.joins("LEFT OUTER JOIN campaigns ON campaigns.user_id = users.id").where.not("campaigns.status IN (?)", [:executed, :settled]).distinct
          # @users = @users.includes(:campaigns).where.not(campaigns: { status: [:executed, :settled] })
        elsif params[:filter] == "campagin_settled"
          @users = @users.joins("LEFT OUTER JOIN campaigns ON campaigns.user_id = users.id").where("campaigns.status IN (?)", [:executed, :settled]).distinct
          # @users = @users.includes(:campaigns).where(campaigns: { status: [:executed, :settled] })
        elsif params[:filter] == "has_campagin"
          @users = @users.joins("LEFT OUTER JOIN campaigns ON campaigns.user_id = users.id").where("campaigns.user_id IS NOT NULL").distinct
        end

        headers['Content-Disposition'] = "attachment; filename=\"发单品牌主记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end

  def show
    authorize! :read, User
    @user = User.find params[:id]
  end

  def live
    authorize! :read, User
    @user = User.find params[:id]
    @user.update(is_live: !@user.is_live)
    redirect_to marketing_dashboard_user_path(@user)
  end

  def active
    authorize! :read, User
    @user = User.find params[:id]
    @user.update(is_active: !@user.is_active)
    redirect_to marketing_dashboard_user_path(@user)
  end

  def recharge
    authorize! :update, User

    render 'recharge' and return if request.method.eql? 'GET'

    if params[:credits].to_f.zero?
      flash[:alert] = "金额不能为空"
      return render 'recharge'
    end

    credits = params[:credits].to_f
    tax = 0

    if params[:need_invoice]
      tax = credits * 0.06
      credits = credits - tax
    end

    recharge_record = RechargeRecord.create(
      credits: credits,
      tax: tax,
      status: "pending",
      receiver_name: params[:receiver_name],
      receiver: @user,
      operator: current_admin_user.email,
      admin_user: current_admin_user,
      need_invoice: params[:need_invoice],
      remark: params[:remark]
    )

    if @user.income(credits, 'manual_recharge', recharge_record)
      recharge_record.update(status: "success")
      if params[:need_invoice]
        @user.increment!(:appliable_credits, (tax + credits))
      end

      if params[:seller_id]
        @user.update(seller_id: params[:seller_id])
      end
      flash[:notice] = '为品牌主充值成功'
    else
      recharge_record.update(status: "failed")

      flash[:alert] = '为品牌主充值失败，请联系技术支持'
    end

    respond_to do |format|
      format.html { redirect_to marketing_dashboard_users_path }
      format.json { head :no_content }
    end
  end

  private
  def set_user
    @user = User.find params[:user_id]
  end
end
