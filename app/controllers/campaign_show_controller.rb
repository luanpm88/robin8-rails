class CampaignShowController < ApplicationController
  skip_before_action  :only => [:show, :share]

  def show
    campaign_id = JSON.parse(Base64.decode64(params[:uuid]))['campaign_id']     rescue nil
    campaign = Campaign.find campaign_id rescue nil
    Rails.logger.error "-----show  -- #{params[:uuid]} --- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    if campaign && campaign.status == 'executing'
      CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip)
      redirect_to campaign.url
    elsif  campaign
      redirect_to campaign.url
    else
      render :text => "你访问的Campaign 不存在"
    end

  end

  def share
    @campaign_invite = CampaignInvite.find_by :id => params[:id]   rescue nil
    @campaign = @campaign_invite.campaign  rescue nil     if @campaign_invite
    render :text => '你访问的Campaign 不存在'          if @campaign.blank?
  end


end
