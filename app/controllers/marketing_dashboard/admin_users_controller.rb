class MarketingDashboard::AdminUsersController < MarketingDashboard::BaseController
  def index
    @admin_users = AdminUser.all.paginate(paginate_params)
  end
end
