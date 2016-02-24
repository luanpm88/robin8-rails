class CampaignShowController < ApplicationController
  skip_before_action  :only => [:show, :share]
  layout 'website'

  def show
    campaign_id = JSON.parse(Base64.decode64(params[:uuid]))['campaign_id']     rescue nil
    @campaign = Campaign.find campaign_id rescue nil
    @campaign_invite = CampaignInvite.find_by(:uuid => params[:uuid])     rescue nil
    return render :text => "你访问的Campaign 不存在" if @campaign.nil?
    Rails.logger.info "-----show ---campaign_status:#{@campaign.status} - campaign_invite:#{@campaign_invite.try(:id)}- #{params[:uuid]} --- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    if  @campaign.status == 'agreed' ||  @campaign_invite.blank?
      redirect_to @campaign.url
    elsif @campaign
      Rails.logger.info "-----show ---campaign_id:#{@campaign_invite.id}-----count"
      CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip, request.user_agent, request.referer)
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
