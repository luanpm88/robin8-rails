class MarketingDashboard::DashboardController < MarketingDashboard::BaseController

  def index
  end

  def edit_password
  end

  def update_password
  	current_admin_user.reset_password(params[:admin_user][:password], params[:admin_user][:password])
    if current_admin_user.errors.empty?
      flash[:notice] = "修改成功"
      redirect_to action: :index
    else
      flash[:alert] = "修改失败, 请重试. 注意: 密码要大于6位"
      render 'edit_password'
    end
  end
end
