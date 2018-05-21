class MarketingDashboard::Utilities::VerifyCodesController < MarketingDashboard::BaseController
  def show
  end

  def create
    code = params[:code].present? ? params[:code] : (1..9).to_a.sample(4).join
    $redis.setex(params[:mobile_number], code.to_s, expires_in: 30.minutes)
    render json: { code: code }
  end
end
