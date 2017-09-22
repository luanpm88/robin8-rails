class WechatGeometryController < ApplicationController


  def kol_register
    @app_download_url = Rails.application.secrets[:download_url]
    Rails.logger.wechat_campaign.info "--kol_register @app_download_url : #{@app_download_url}"
    @tag = params[:tag]
    render :layout => false
  end

  def sms_request
    if !Rails.env.development? and !sms_request_is_valid?
      return render json: { error: "请求异常，请重新尝试" }
    end

    mobile_number = params[:mobile_number]
    return render json: {error: "必须填写手机号"} if mobile_number.blank?

    # kol_exists = Kol.find_by(mobile_number: mobile_number)
    # return render json: {error: "用户已注册"} if kol_exists #Kol already exists

    total_send_key = "wechat_campaign_kol_register_send_sms_count"
    send_count =  Rails.cache.fetch(total_send_key).to_i || 1
    Rails.cache.write(total_send_key, send_count + 1, :expires_in => 50.hours)
    Rails.logger.wechat_campaign.info "--sms_request: sms count #{send_count}"

    sms_client = YunPian::SendRegisterSms.new(mobile_number)

    res = sms_client.send_sms  rescue {}
    Rails.logger.wechat_campaign.info "--sms_request: send sms code #{res}"
    render json: res
  end

  def kol_create
    return render json: {error: "请填写短信验证码" } unless params[:sms_code]
    return render json: {error: "必须填写手机号" } unless params[:mobile_number]

    verify_code = Rails.cache.fetch(params[:mobile_number])
    return render json: {error: "短信验证码错误" } unless verify_code == params[:sms_code]

    kol_exists = Kol.find_by(mobile_number: params[:mobile_number])
    # return render json: {error: "Kol already exists"} if kol_exists

    if kol_exists
      kol_exists.admintags << Admintag.find_or_create_by(tag: 'geometry')
      return render json: {url: wechat_geometry_geometry_path}
    else
      ip = (request.remote_ip rescue nil) || request.ip
      kol = Kol.new(mobile_number: params[:mobile_number],
                    name: Kol.hide_real_mobile_number(params[:mobile_number]),
                    current_sign_in_ip: ip)

      if kol.save
         kol.admintags << Admintag.find_or_create_by(tag: 'geometry')
            return render json: {url: wechat_geometry_geometry_path}
      else
        Rails.logger.wechat_campaign.info "--kol_create: campaign not found"
        return render json: {error: '注册失败'}
      end
    end

  end

  def geometry
    @app_download_url = Rails.application.secrets[:download_url]
    render :layout => false
    # render "geometry"
  end

  private

  def tmp_token kol, campaign
    password = "#{kol.id}-#{campaign.id}-wechat-campaign-Robin8"
    Rails.logger.wechat_campaign.info "--tmp_token: password #{password}"
    Digest::MD5.hexdigest(Digest::MD5.hexdigest(Digest::SHA256.hexdigest(password)))
  end

end