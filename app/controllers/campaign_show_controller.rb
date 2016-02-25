class CampaignShowController < ApplicationController
  skip_before_action  :only => [:show, :share]
  layout 'website'

  def show
    uuid_params = JSON.parse(Base64.decode64(params[:uuid]))

    campaign_id = uuid_params['campaign_id']
    @campaign = Campaign.find campaign_id rescue nil
    return render :text => "你访问的Campaign 不存在" if @campaign.nil?
    
    Rails.logger.info "-----show ---#{@campaign.status} -- #{params[:uuid]} --- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    
    if @campaign && @campaign.status == 'agreed'
      redirect_to @campaign.url
    elsif @campaign
      if @campaign.is_cpa?
        deal_with_cpa_campaign uuid_params
      else
        CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, other_options)
        redirect_to @campaign.url
      end
    end
  end

  def share
    @campaign_invite = CampaignInvite.find_by :id => params[:id]   rescue nil
    @campaign = @campaign_invite.campaign  rescue nil     if @campaign_invite
    #Rails.logger.info "-----show ---#{@campaign.status} --0000--- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    # if @campaign && @campaign.status != 'agreed'
    #   CampaignShowWorker.perform_async(@campaign_invite.uuid, cookies[:_robin8_visitor], request.remote_ip)
    # else
    #   # render :text => "你访问的Campaign 不存在"
    # end
  end

  private
  def deal_with_cpa_campaign uuid_params
    uuid_params.symbolize_keys!
    other_options = {}
    other_options[:step] = (uuid_params[:step] || 1).to_i

    CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, other_options)
    if other_options[:step] == 1
      redirect_to @campaign.url
    else
      campaign_action_url = CampaignActionUrl.find_by :id => uuid_params[:campaign_action_url_id]
      redirect_to (campaign_action_url.try(:action_url) || "http://robin8.net")
    end
  end
end
