class CampaignShowController < ApplicationController
  skip_before_action  :only => [:show, :share]
  layout 'website'

  def show
    uuid_params = JSON.parse(Base64.decode64(params[:uuid]))
    campaign_id = uuid_params['campaign_id']
    if uuid_params["campaign_action_url_identifier"].present?
      @campaign_action_url = CampaignActionUrl.find_by :identifier => uuid_params["campaign_action_url_identifier"]
      @campaign = @campaign_action_url.campaign rescue nil
    else
      @campaign = Campaign.find campaign_id rescue nil
      @campaign_invite = CampaignInvite.find_by(:uuid => params[:uuid])     rescue nil
    end
    return render :text => "你访问的Campaign 不存在" if @campaign.nil?

    Rails.logger.info "-----show ---#{@campaign.status} -- #{params[:uuid]} --- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    if @campaign and @campaign.is_cpa?
      return deal_with_cpa_campaign uuid_params
    end

    if @campaign.status == 'agreed' ||  @campaign_invite.blank?
      redirect_to @campaign.url
    else
      if Rails.env.development?
        CampaignShowWorker.new.perform(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, request.env['HTTP_X_FORWARDED_FOR'], {})
      else
        CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, request.env['HTTP_X_FORWARDED_FOR'], {})
      end
      redirect_to @campaign.url
    end
  end

  def share
    @campaign_invite = CampaignInvite.find_by :id => params[:id]   rescue nil
    @campaign = @campaign_invite.campaign  rescue nil     if @campaign_invite
  end

  private
  def deal_with_cpa_campaign uuid_params
    if ["unexecute", "agreed"].include?(@campaign.status)
      redirect_to @campaign.url
      return
    end

    uuid_params.symbolize_keys!
    other_options = {}
    other_options[:step] = (uuid_params[:step] || 1).to_i

    CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, request.env['HTTP_X_FORWARDED_FOR'], other_options)
    if other_options[:step] == 1
      redirect_to @campaign.url
    else
      @campaign_action_url = CampaignActionUrl.find_by :identifier => uuid_params[:campaign_action_url_identifier]
      redirect_to (@campaign_action_url.try(:action_url) || "http://robin8.net")
    end
  end
end
