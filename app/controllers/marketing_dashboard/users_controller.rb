class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  before_action :set_user, only: [:recharge, :withdraw]

  def index
    @users = User.all.order('created_at DESC').paginate(paginate_params)
  end

  def show
    @user = User.find params[:id]
  end

  def search
    render 'search' and return if request.method.eql? 'GET'

    search_by = params[:search_key]

    @users = User.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params)

    render 'index'
  end

  def recharge

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
