class RegisteredInvitationsController < ApplicationController

  def create
    return render json: {error: "请填写短信验证码" } unless params[:sms_code]
    return render json: {error: "必须填写手机号" } unless params[:mobile_number]

    verify_code = $redis.get(params[:mobile_number])
    return render json: {error: "短信验证码错误" } unless verify_code == params[:sms_code]
    return render json: {error: "手机号已经被注册" } if Kol.where(mobile_number: params[:mobile_number]).exists?
    @kol = Kol.where(id: params[:invite_code]).take
    @kol.registered_invitation_count.increment
    if @kol.registered_invitation_count > 100
      return render json: {error: "短信错误"}
    end

    return render json: {error: "错误的邀请码" } unless @kol.present?

    @invitation = RegisteredInvitation.where(mobile_number: params[:mobile_number]).first_or_create(
      inviter_id: @kol.id,
      status: "pending"
    )

    if @invitation.save
      render json: {url: Rails.application.secrets[:download_url] || root_url }
    else
      render json: {error: "邀请异常，请重新尝试" }
    end
  end

  def sms
    if !Rails.env.development? and !sms_request_is_valid?
      return render json: { error: "请求异常，请重新尝试" }
    end

    mobile_number = params[:mobile_number]
    return render json: {error: "必须填写手机号"} if mobile_number.blank?

    number_existed = Kol.check_mobile_number mobile_number
    return render json: {error: "手机号已经被注册"} if number_existed

    total_send_key = "robin8_send_sms_count"
    send_count =  $redis.get(total_send_key).to_i || 1
    $redis.setex(total_send_key, 50.hours, send_count.succ)
    Rails.logger.sms_spider.info "发送的 有效的量已经超过了 #{send_count}"

    sms_client = YunPian::SendRegisterSms.new(mobile_number)

    res = sms_client.send_sms  rescue {}
    Rails.logger.sms_spider.info "send sms code #{res}"
    render json: res
  end
end
