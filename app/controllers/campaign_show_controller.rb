class CampaignShowController < ApplicationController
  skip_before_action  :only => [:show, :share]
  layout 'website'

  # 先到visit 获取来源, 根据点击量,来决定是否需要手动授权
  def visit
    # if wechat campaign is finished, we're sharing URL with param ?campaign_id
    # and here redirect on finished campaign URL
    if params[:campaign_id]
      campaign = Campaign.find params[:campaign_id] rescue nil
      if campaign
        redirect_to campaign.url
      end
    else
      Rails.logger.info "------referer:#{request.referer}"
      Rails.cache.write("visit_url_#{cookies[:_robin8_visitor]}", request.url)
      # Includes invitation which were soft-deleted after campaign has ended
      campaign_invite = CampaignInvite.unscoped.find params[:id]
      if campaign_invite.campaign.deadline < Time.now - 10.days
        render text: '活动已结束，该页面不可再访问'
      else
        redirect_to campaign_invite.origin_share_url
      end
    end
  end

  def show
    sns_info = $weixin_client.get_oauth_access_token(params[:code])
    openid = sns_info.result['openid']    rescue nil
    uuid_params = JSON.parse(Base64.decode64(params[:uuid]))   rescue {}
    campaign_id = uuid_params['campaign_id']
    if uuid_params["campaign_action_url_identifier"].present?
      @campaign_action_url = CampaignActionUrl.find_by :identifier => uuid_params["campaign_action_url_identifier"]
      @campaign = @campaign_action_url.campaign rescue nil
    else
      @campaign = Campaign.find campaign_id rescue nil
      @campaign_invite = CampaignInvite.find_by(:uuid => params[:uuid])     rescue nil
    end

    return render :text => "你访问的Campaign 不存在" if @campaign.nil?
    visit_url = Rails.cache.read("visit_url_#{cookies[:_robin8_visitor]}") || request.url
    Rails.logger.info "-----show ----openid:#{openid}---#{@campaign.status} ---visit_url:#{visit_url}--- #{params[:uuid]} ------ #{request.remote_ip}"
    if @campaign and @campaign.is_cpa_type?
      return deal_with_cpa_campaign(uuid_params, openid)
    end

    # wechat_auth_type ==  'info'
    if sns_info.result['scope'] == 'snsapi_userinfo'
      user_info = $weixin_client.get_oauth_userinfo(sns_info.result['openid'], sns_info.result['access_token'])
      if Rails.env.staging? or Rails.env.qa?
        KolWechatWorker.new.perform(@campaign.wechat_auth_type, @campaign_invite.kol_id, user_info.result)
      else
        KolWechatWorker.perform_async(@campaign.wechat_auth_type, @campaign_invite.kol_id, user_info.result)
      end
    end

    if @campaign.status == 'agreed' ||  @campaign_invite.blank?
      redirect_to @campaign.url
    else
      if Rails.env.development?
        CampaignShowWorker.new.perform(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, request.env['HTTP_X_FORWARDED_FOR'], visit_url, openid, Time.now,  {})
      else
        CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, request.env['HTTP_X_FORWARDED_FOR'], visit_url, openid, Time.now,  {})
      end
      redirect_to @campaign.url
    end
  end

  def share
    @campaign_invite = CampaignInvite.find_by :id => params[:id]   rescue nil
    @campaign = @campaign_invite.campaign  rescue nil     if @campaign_invite
  end

  private
  def deal_with_cpa_campaign uuid_params, openid
    uuid_params.symbolize_keys!
    other_options = {}
    other_options[:step] = (uuid_params[:step] || 1).to_i

    unless ["unpay", "unexecute", "agreed"].include?(@campaign.status)
      CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, request.env['HTTP_X_FORWARDED_FOR'], request.url, openid, Time.now, other_options)
    end

    if other_options[:step] == 1
      redirect_to @campaign.url
    else
      @campaign_action_url = CampaignActionUrl.find_by :identifier => uuid_params[:campaign_action_url_identifier]
      redirect_to (@campaign_action_url.try(:action_url) || "http://robin8.net")
    end
  end
end
