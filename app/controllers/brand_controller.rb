class BrandController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_alipay_request, only: :index
  layout 'brand'
  def index
    @brand_home_props = { brand: current_user }
  end

  # def qiniu
  #   render json: { uptoken: Qiniu::Auth.generate_uptoken({
  #     scope: Rails.application.secrets.qiniu[:bucket],
  #     deadline: (Time.zone.now + 1.hours).to_i,
  #     returnBody: '{
  #       "name": $(fname),
  #       "size": $(fsize),
  #       "w": $(imageInfo.width),
  #       "h": $(imageInfo.height),
  #       "hash": $(etag)
  #     }'
  #   }) }
  # end

  private
  def authenticate_user!
    if current_kol
      sign_in(:user, current_kol.user) if not user_signed_in?
    else
      sign_out(:user) and flash[:alert] = "请您先登录或注册新账号" if user_signed_in?
    end

    if is_super_vistor?
      sign_in_as_super_visitor(params[:user_id])
    elsif user_signed_in?
      super
    else
      redirect_to login_url(subdomain: :passprot, ok_url: brand_url(subdomain: false))
    end
  end

  def is_super_vistor?
    params[:super_visitor_token] == Rails.cache.fetch("super_visitor_token") && params[:user_id] ? true : false
  end

  def sign_in_as_super_visitor(user_id)
    sign_out current_user if current_user
    sign_in User.find_by(id: params[:user_id])
    cookies[:is_super_vistor] = { value: true, expires: 5.minutes.from_now}
  end

  def redirect_alipay_request
    if (params[:from] == 'pay_campaign') and params.keys.include?('buyer_id') and params.keys.include?('trade_no') and params.keys.include?('trade_status') and params.keys.include?('sign')
      redirect_to '/brand/'
    elsif params.keys.include?('buyer_id') and params.keys.include?('trade_no') and params.keys.include?('trade_status') and params.keys.include?('sign')
      redirect_to '/brand/financial/recharge'
    end
  end

end
