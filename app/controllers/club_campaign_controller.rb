class ClubCampaignController < ApplicationController
  before_action :set_campaign, only: [:campaign_page, :kol_register, :campaign_details]

  def campaign_page
    @club = params[:club]
    render :layout => false
  end

  def kol_register
    @app_download_url = Rails.application.secrets[:download_url]
    Rails.logger.wechat_campaign.info "--kol_register @app_download_url : #{@app_download_url}"
    @club = params[:club]
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
        kol_exists.add_campaign_id campaign_id
        kol_exists.approve_campaign(campaign_id)
      end
      club = Club.find_by(club_name: params[:club])
      ClubMember.create(club_id: club.id , kol_id: kol_exists.id)
      # kol_exists.clubs << Club.find_or_create_by(club_name: params[:club]) if params[:club].present?
      return render json: {url: club_campaign_campaign_details_path(campaign_id: campaign_id) }
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
          kol.add_campaign_id campaign_id
          kol.approve_campaign(campaign_id)
        end
        club = Club.find_by(club_name: params[:club])
        ClubMember.create(club_id: club.id , kol_id: kol.id)
        return render json: {url: club_campaign_campaign_details_path(campaign_id: campaign_id) }     
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
      redirect_to club_campaign_campaign_page_url(campaign_id: campaign_id)
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
