class WechatCampaignController < ApplicationController

  before_action :set_campaign, only: [:campaign_page, :kol_register, :campaign_details]

  def campaign_page
    @tag = params[:tag]
    render :layout => false
  end

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

    Rails.logger.wechat_campaign.info "--kol_create: kol_exists: #{kol_exists}"
    if kol_exists
      campaign_id = params[:campaign_id]
      Rails.logger.wechat_campaign.info "campaign ID: #{campaign_id}"
      campaign = Campaign.find(campaign_id) rescue nil
      token = tmp_token kol_exists, campaign
      cookies[:_robin8_wechat_campaign] = token
      cookies[:_robin8_wechat_campaign_id] = kol_exists.id
      Rails.logger.wechat_campaign.info "--kol_create: cookies[:_robin8_wechat_campaign] : #{token}"
      Rails.logger.wechat_campaign.info "--kol_create: cookies[:_robin8_wechat_campaign_id] : #{kol_exists.id}"

      cache_key = "wechat-campaign-token-#{kol_exists.id}-#{campaign_id}"
      Rails.cache.write(cache_key, token , :expires_in => 1.hour)
      Rails.logger.wechat_campaign.info "--kol_create: cache_key: #{cache_key}"

      Rails.logger.wechat_campaign.info "--kol_create: campaign status: #{campaign.status}"
      if campaign and campaign.status == 'executing'
        if campaign.per_budget_type == 'recruit'
          campaign_invite = kol_exists.campaign_invites.where(:campaign_id => params[:campaign_id]).first rescue nil
          return render json: {error: '该活动不存在'} if campaign.blank? || !campaign.is_recruit_type? || !kol_exists.receive_campaign_ids.include?("#{params[:campaign_id]}")
          return render json: {error: '该活动已过报名时间或者您已经接收本次活动'} if !campaign.can_apply || campaign.status != 'executing' || campaign_invite.present?
          return render json: {error: '抱歉，本次活动不接受影响力分数低于#{campaign.influence_score_target.get_score_value}的KOL用户报名'} if campaign.influence_score_target && kol_exists.influence_score.to_i < campaign.influence_score_target.get_score_value
          campaign_invite = kol_exists.apply_campaign(params)
        else
          kol_exists.add_campaign_id campaign_id
          kol_exists.approve_campaign(campaign_id)
        end
      end
      kol_exists.admintags << Admintag.find_or_create_by(tag: params[:tag]) if params[:tag].present?
      if campaign.per_budget_type == 'recruit'
        render json: {url: Rails.application.secrets[:download_url] || root_url }
      else
        return render json: {url: wechat_campaign_campaign_details_path(campaign_id: campaign_id) }
      end
    else
      ip = (request.remote_ip rescue nil) || request.ip
      kol = Kol.new(mobile_number: params[:mobile_number],
                    name: Kol.hide_real_mobile_number(params[:mobile_number]),
                    current_sign_in_ip: ip)

      if kol.save
        campaign_id = params[:campaign_id]
        campaign = Campaign.find(campaign_id) rescue nil
        token = tmp_token kol, campaign
        cookies[:_robin8_wechat_campaign] = token
        cookies[:_robin8_wechat_campaign_id] = kol.id
        Rails.logger.wechat_campaign.info "--kol_create: cookies[:_robin8_wechat_campaign] : #{token}"
        Rails.logger.wechat_campaign.info "--kol_create: cookies[:_robin8_wechat_campaign_id] : #{kol.id}"

        cache_key = "wechat-campaign-token-#{kol.id}-#{campaign_id}"
        Rails.cache.write(cache_key, token , :expires_in => 1.hour)
        Rails.logger.wechat_campaign.info "--kol_create: cache_key: #{cache_key}"

        Rails.logger.wechat_campaign.info "--kol_create: campaign status: #{campaign.status}"
        if campaign and campaign.status == 'executing'
          if campaign.per_budget_type == 'recruit'
            campaign_invite = kol.campaign_invites.where(:campaign_id => params[:campaign_id]).first rescue nil
            return render json: {error: '该活动不存在'} if campaign.blank? || !campaign.is_recruit_type?
            return render json: {error: '该活动已过报名时间或者您已经接收本次活动！'} if !campaign.can_apply || campaign.status != 'executing' || campaign_invite.present?
            return render json: {error: '抱歉，本次活动不接受影响力分数低于#{campaign.influence_score_target.get_score_value}的KOL用户报名'} if  campaign.influence_score_target && kol.influence_score.to_i < campaign.influence_score_target.get_score_value

            kol.add_campaign_id(campaign_id)
            campaign_invite = kol.apply_campaign(params)
          else
            kol.add_campaign_id campaign_id
            kol.approve_campaign(campaign_id)
          end
        end
        kol.admintags << Admintag.find_or_create_by(tag: params[:tag]) if params[:tag].present?
        if campaign.per_budget_type == 'recruit'
          render json: {url: Rails.application.secrets[:download_url] || root_url }
        else
          return render json: {url: wechat_campaign_campaign_details_path(campaign_id: campaign_id) }
        end
      else
        Rails.logger.wechat_campaign.info "--kol_create: campaign not found"
        return render json: {error: 'Campaign not found'}
      end
    end

  end

  def campaign_details
    client_token = cookies[:_robin8_wechat_campaign]
    kol_id = cookies[:_robin8_wechat_campaign_id]
    Rails.logger.wechat_campaign.info "--campaign_details: client_token #{client_token}"
    Rails.logger.wechat_campaign.info "--campaign_details: kol_id #{kol_id}"
    campaign_id = params[:campaign_id]
    campaign = Campaign.find(campaign_id)
    Rails.logger.wechat_campaign.info "--campaign_details: campaign_id #{campaign_id}"

    cache_key = "wechat-campaign-token-#{kol_id}-#{campaign_id}"
    cached_token = Rails.cache.fetch(cache_key)
    Rails.logger.wechat_campaign.info "--campaign_details: cache_key #{cache_key}"

    @campaign_info_box = campaign.per_budget_type == 'cpt' ? campaign.remark : nil rescue nil
    Rails.logger.wechat_campaign.info "--campaign_details: @campaign_info_box #{@campaign_info_box}"

    if client_token and cached_token and client_token == cached_token
      kol = Kol.find(kol_id)
      Rails.logger.wechat_campaign.info "--campaign_details: kol_id #{kol_id}"
      campaign_invite = campaign.get_campaign_invite(kol.id) rescue nil
      Rails.logger.wechat_campaign.info "--campaign_details: campaign_invite.id #{campaign_invite.id}"
      if campaign_invite
        campaign_invite_uuid = campaign_invite.uuid
        Rails.logger.wechat_campaign.info "--campaign_details: campaign_invite_uuid #{campaign_invite_uuid}"
        @share_url = campaign_invite.visit_url if campaign_invite_uuid
        Rails.logger.wechat_campaign.info "--campaign_details: @share_url #{@share_url}"
      end
    else
      redirect_to wechat_campaign_campaign_page_url(campaign_id: campaign_id)
      return nil
    end
    # if auth failed, user will share standard campaign's url
    @share_url ||= "#{Rails.application.secrets.domain}/campaign_visit?campaign_id=#{campaign.id}" rescue ''
    Rails.logger.wechat_campaign.info "--campaign_details: @share_url #{@share_url}"
    @app_download_url = Rails.application.secrets[:download_url]
    render :layout => false
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id]) rescue nil
    unless @campaign
        redirect_to '/'
    end
  end

  def tmp_token kol, campaign
    password = "#{kol.id}-#{campaign.id}-wechat-campaign-Robin8"
    Rails.logger.wechat_campaign.info "--tmp_token: password #{password}"
    Digest::MD5.hexdigest(Digest::MD5.hexdigest(Digest::SHA256.hexdigest(password)))
  end

end
