class CampaignShowController < ApplicationController
  skip_before_action  :only => [:show, :share]
  layout 'website'

  def show
    uuid_params = Base64.decode64(params[:uuid])

    campaign_id = JSON.parse(uuid_params)['campaign_id']     rescue nil
    @campaign = Campaign.find campaign_id rescue nil
    return render :text => "你访问的Campaign 不存在" if @campaign.nil?
    Rails.logger.info "-----show ---#{@campaign.status} -- #{params[:uuid]} --- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    if @campaign && @campaign.status == 'agreed'
      redirect_to @campaign.url
    elsif @campaign
      other_options = {}

      if @campaign.is_cpa?
        other_options[:step] = (uuid_params["step"] || 1).to_i
        if other_options[:step] == 1
          campaign_invite = CampaignInvite.where(:uuid => params[:uuid]).first     rescue nil
          
          expired_at = (@campaign.deadline > Time.now ? @campaign.deadline : Time.now)
          Rails.cache.write(cookies[:_robin8_visitor] + ":cpa_campaign_id:#{@campaign.id}", campaign_invite.id, :expired_at => expired_at) if campaign_invite
        end
      end

      CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer, other_options)
      redirect_to @campaign.url
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


end
