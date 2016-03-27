class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  before_action :set_user, only: [:recharge, :withdraw]

  def index
    @users = User.all.paginate(paginate_params)
  end

  def recharge
    render 'recharge' and return if request.method.eql? 'GET'

    @user.income params[:credits].to_f, 'manaual_recharge'

    respond_to do |format|
      format.html { redirect_to marketing_dashboard_users_path, notice: 'Recharge successfully!' }
      format.json { head :no_content }
    end
  end

  def withdraw
    render 'withdraw' and return if request.method.eql? 'GET'

    # TODO: make sure have enough money
    @user.payout params[:credits].to_f, 'manaual_withdraw'

    respond_to do |format|
      format.html { redirect_to marketing_dashboard_users_path, notice: 'Payout successfully!' }
      format.json { head :no_content }
    end
  end

  private
  def set_user
    @user = User.find params[:user_id]
  end
end
