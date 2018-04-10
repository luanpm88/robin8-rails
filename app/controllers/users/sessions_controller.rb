require 'rqrcode'

module Users
  class SessionsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    layout 'passport'
    respond_to :html, :json

    def new
    end

    def create
      auth_params = params.require("user").permit(:login, :password)

      unless @kol = Kol.authenticate_password(auth_params)
        return render json: { error: "登录失败，账号或密码错误！" }, status: :bad_request
      end

      @user = @kol.find_or_create_brand_user
      set_union_access_token(@kol)

      render json: { msg: "登录成功，正在为您跳转...", ok_url: register_edit_path(params.permit(:ok_url)) }, status: :ok
    end

    def destroy
      flash[:notice] = "您已经成功退出了登录"
      clear_union_access_token

      redirect_to params[:ok_url].presence || (Rails.env.development? ? root_url : root_url(subdomain: :passport) )
    end

    def scan
      @uuid, @url = uuid_and_qr_code_url
    end

    def scan_submit
      unless params[:id]
        flash[:error] = "请重新登录手机App并重新扫描二维码"
        return redirect_to login_url(params.permit(:ok_url))
      end
      unless params[:token]
        flash[:error] = "扫码失败，请重试"
        return redirect_to login_url(params.permit(:ok_url))
      end
      unless $redis.get(params[:token]) == params[:id]
        flash[:error] = "扫码登录出错，请尝试其他方式"
        return redirect_to login_url(params.permit(:ok_url))
      end
      @kol = Kol.find(params[:id])
      @user = @kol.find_or_create_brand_user
      $redis.del params[:token]
      set_union_access_token(@kol)
      redirect_to params[:ok_url].presence || brand_url(subdomain: false)
    end

    def sms
      phone = params[:phone]
      return render json: { error: "没填写或无效的手机号码" }, status: :bad_request unless phone

      phone_exist = Kol.check_mobile_number phone
      return render json: { error: "没找到绑定此手机号的注册用户，请先注册" }, status: :forbidden if params[:forget_password] and not phone_exist
      return render json: { msg: "手机号已经被绑定，可以直接登录", skip: true}, status: :created if not params[:forget_password] and phone_exist
      return render json: { error: "请求短信验证码过于频繁，请稍后重试"}, status: :forbidden unless 60.seconds.ago.to_i > session[:sms_sent_at].to_i
      return render json: { error: "请求了过多的短信验证码，请稍后重试" }, status: :forbidden unless sms_request_is_valid?

      if params[:bypass]
        return render json: { error: "无法请求短信验证码，请稍后重试" }, status: :forbidden unless sms_request_is_valid_for_login_user?
      else
        return render json: { error: "图片验证码错误，请重新填写" }, status: :bad_request unless verify_rucaptcha?
      end

      unless Rails.env.development?
        total_send_key = "robin8_send_sms_count"
        send_count =  Rails.cache.fetch(total_send_key).to_i || 1
        Rails.cache.write(total_send_key, send_count + 1, :expires_in => 50.hours)
        Rails.logger.sms_spider.error "发送的 有效的量已经超过了 #{send_count}"
      end

      sms_client = YunPian::SendRegisterSms.new(phone)
      res = sms_client.send_sms rescue {}
      Rails.logger.sms_spider.error "send sms code #{res}"
      session[:sms_sent_at] = Time.now.to_i

      render json: res.merge({ msg: "短信验证码已经发送", ts: session[:sms_sent_at] }), status: :ok
    end

    def after_sign_out_path_for(resource_or_scope)
      login_path
    end

    private

    def uuid_and_qr_code_url
      uuid = Base64.encode64(SecureRandom.uuid).gsub("\n","")
      $redis.set "login_uuid_#{uuid}", true
      $redis.expire "login_uuid_#{uuid}", 1800
      url = RQRCode::QRCode.new(uuid, size: 12, level: :h).as_svg( module_size: 3 )
      return uuid, url
    end

  end
end
