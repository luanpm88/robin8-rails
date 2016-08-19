class MarketingDashboard::AdminUsersController < MarketingDashboard::BaseController
  def index
    @admin_users = AdminUser.all.order('created_at DESC').paginate(paginate_params)
  end

  def new
    @admin_user = AdminUser.new
  end

  def create
    @admin_user = AdminUser.new(params.require(:admin_user).permit(:email, :password))
    if @admin_user.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败, 请重试. 注意: 账户名为邮箱，密码要大于6位, 账户名称不能重复"
      render 'new'
    end
  end

  def edit
    @admin_user = AdminUser.find(params[:id])
  end

  def update
    @admin_user = AdminUser.find(params[:id])
    @admin_user.update_attributes!(params.require(:admin_user).permit(:email))
    @admin_user.reset_password(params.require(:admin_user)[:password], params.require(:admin_user)[:password])
    if @admin_user.errors.empty?
      flash[:notice] = "修改成功"
      redirect_to action: :index
    else
      flash[:alert] = "修改失败, 请重试. 注意: 账户名为邮箱，密码要大于6位, 账户名称不能重复"
      render 'edit'
    end
  end

  def destroy
    @admin_user = AdminUser.find(params[:id])
    @admin_user.try(:delete)
    if @admin_user.destroyed?
      flash[:notice] = "删除成功"
      redirect_to action: :index
    else
      flash[:alert] = "删除失败，请重试"
    end
  end

  def auth
    @admin_users = AdminUser.all.order('created_at DESC').paginate(paginate_params)
  end

  def edit_auth
    @admin_user = AdminUser.find(params[:id])
  end

  def update_auth
    @admin_user = AdminUser.find(params[:id])
    @admin_user.roles.delete_all
    params[:admin_user][:roles].each do |role|
      @admin_user.add_role role
    end
    if @admin_user.roles.any?
      flash[:notice] = "为 #{@admin_user.email} 修改权限成功"
      redirect_to action: :auth
    end
  end
end
