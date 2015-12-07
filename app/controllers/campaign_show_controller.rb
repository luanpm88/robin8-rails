class CampaignShowController < ApplicationController

  def show
    campaign_id = Base64.decode(params[:uuid])[:compaign_id]     rescue nil
    campaign = Campaign.find campaign_id rescue nil
    if campaign
      CampaignShow.perform_sync(params[:uuid], cookies[:_robin8_visitor], request.remote_ip)
      redirect_to campaign.url
    else
      render :text => "你访问的Campaign 不存在"
    end

  end


end
