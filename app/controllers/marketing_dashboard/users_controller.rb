class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  before_action :set_user, only: [:recharge, :withdraw]

  def index
    @users = User.all.order('created_at DESC').paginate(paginate_params)
  end

  def recharge
    render 'recharge' and return if request.method.eql? 'GET'

    @user.income params[:credits].to_f, 'manaual_recharge'

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
