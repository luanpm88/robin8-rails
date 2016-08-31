class MarketingDashboard::VerifyCodesController < MarketingDashboard::BaseController
  def new

  end

  def get_verify_code
    code = (1..9).to_a.sample(4).join
    Rails.cache.write(params[:mobile_number], code.to_s, expires_in: 30.minutes)
    render json: { code: code }
  end
end
