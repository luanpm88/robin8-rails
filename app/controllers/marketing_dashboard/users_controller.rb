class MarketingDashboard::UsersController < MarketingDashboard::BaseController
  def index
    @users = User.all.paginate(:page => 1, :per_page => 20)
  end
end
