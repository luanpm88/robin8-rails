class MarketingDashboard::Utilities::OpenTokensController < MarketingDashboard::BaseController
  def index
    @users = []

    $redis.hgetall(OpenAPI::STORE_KEY).each do |t, i|
      user = User.find(i)
      user.open_token = t
      @users << user
    end
  end

  def create
    @user = User.find(params[:user_id])

    token = $redis.hgetall(OpenAPI::STORE_KEY).invert[@user.id.to_s]
    $redis.hdel(OpenAPI::STORE_KEY, token)

    token = SecureRandom.hex(32)
    $redis.hset(OpenAPI::STORE_KEY, token, @user.id)

    redirect_to marketing_dashboard_utilities_open_tokens_path
  end
end
