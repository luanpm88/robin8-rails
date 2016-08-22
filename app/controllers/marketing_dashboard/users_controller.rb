class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  before_action :set_user, only: [:recharge, :withdraw]

  def index
    authorize! :read, User

    @users = User.where(:is_active => true)
    @q = @users.ransack(params[:q])
    @users = @q.result.order('created_at DESC').paginate(paginate_params)
  end

  def show
    authorize! :read, User
    @user = User.find params[:id]
  end

  def recharge
    authorize! :update, User

    render 'recharge' and return if request.method.eql? 'GET'
    if params[:need_invoice] && params[:credits].present?
      credits = params[:credits].to_i / 1.06
      tax = params[:credits].to_i - credits
      @user.income credits.to_f, 'manual_recharge'
      @user.increment!(:appliable_credits, (tax+credits))
    else
      @user.income params[:credits].to_f, 'manual_recharge'
    end

    respond_to do |format|
      format.html { redirect_to marketing_dashboard_users_path, notice: 'Recharge successfully!' }
      format.json { head :no_content }
    end
  end

  private
  def set_user
    @user = User.find params[:user_id]
  end
end
