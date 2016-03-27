class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  def index
    @users = User.all.paginate(paginate_params)
  end
end
