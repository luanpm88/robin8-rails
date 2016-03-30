class MarketingDashboard::AdminUsersController < MarketingDashboard::BaseController
  def index
    @admin_users = AdminUser.all.order('created_at DESC').paginate(paginate_params)
  end
end
