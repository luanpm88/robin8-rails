class CampaignShowController < ApplicationController
  skip_before_action :show

  def show
    campaign_id = JSON.parse(Base64.decode64(params[:uuid]))['campaign_id']     rescue nil
    campaign = Campaign.find campaign_id rescue nil
    Rails.logger.error "-----show  -- #{params[:uuid]} --- #{cookies[:_robin8_visitor]} --- #{request.remote_ip}"
    if campaign
      CampaignShowWorker.perform_async(params[:uuid], cookies[:_robin8_visitor], request.remote_ip)
      redirect_to campaign.url
    else
      render :text => "你访问的Campaign 不存在"
    end

  end


end
