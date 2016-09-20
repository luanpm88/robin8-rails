class CommonsController < ApplicationController

  def read_hot_item
    @hot_item = HotItem.find params[:id]
    render :text => '你找的榜单没有找到' if @hot_item.nil?
    @hot_item.redis_read_count.increment
    redirect_to @hot_item.origin_url
  end

  def material
    uuid_params = JSON.parse(Base64.decode64(params[:uuid]))
    puts uuid_params
    invite_id = uuid_params['campaign_invite_id']
    material_url = uuid_params['material_url']
    campaign_invite =  CampaignInvite.find(invite_id)               rescue nil
    if campaign_invite  && campaign_invite.campaign.is_recruit_type?
      campaign_invite.redis_avail_click.increment
      campaign_invite.campaign.redis_total_click.increment
    end
    redirect_to material_url
  end
end
