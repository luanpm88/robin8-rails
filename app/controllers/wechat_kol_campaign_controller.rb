class WechatKolCampaignController < ApplicationController
  before_action :valid_request?

  def campaign
    Rails.logger.wechat_kol_campaign.info "--checked: #{params}"
    kol = Kol.find_or_create_by(channel: params[:cid, cid: params[:cid])
    kol.add_campaign_id @campaign.id
    kol.approve_campaign @campaign_id
    @campaign_invite = @campaign.get_campaign_invite(kol.id) rescue nil
    if @campaign_invite
      campaign_invite_uuid = @campaign_invite.uuid
      Rails.logger.wechat_kol_campaign.info "--campaign_details: campaign_invite_uuid #{campaign_invite_uuid}"
      @share_url = @campaign_invite.visit_url if campaign_invite_uuid
      Rails.logger.wechat_kol_campaign.info "--campaign_details: @share_url #{@share_url}"
    end
    @share_url ||= "#{Rails.application.secrets.domain}/campaign_visit?campaign_id=#{campaign.id}" rescue ''
    Rails.logger.wechat_kol_campaign.info "--campaign_details: @share_url #{@share_url}"
    @app_download_url = Rails.application.secrets[:download_url]
    render :layout => false
  end 

  private

  def valid_request?
    key = "RANDOM_KEY"
    data = "id=#{params[:id]}&channel_id=#{params[:channel_id]}&cid=#{params[:cid]}&nonce=#{params[:nonce]}&timestamp=#{params[:timestamp]}"
    digest = OpenSSL::Digest.new('sha1')
    hmac = OpenSSL::HMAC.hexdigest(digest, key, data)
    @campaign = Campaign.find(params[:campaign_id]) rescue nil
    if hmac != params[:signature] || @campaign
      Rails.logger.wechat_kol_campaign.info "--check-error: #{params}"
      render text: "error", status: "422" and return
    end
  end
end