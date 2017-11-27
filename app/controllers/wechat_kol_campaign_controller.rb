class WechatKolCampaignController < ApplicationController
  before_action :valid_request?

  def campaign
    Rails.logger.wechat_kol_campaign.info "--checked: #{params}"
    kol = Kol.find_or_create_by(channel: params[:channel_id], cid: params[:cid])
    kol.add_campaign_id params[:campaign_id]
    kol.approve_campaign params[:campaign_id]
    @campaign_invite = @campaign.get_campaign_invite(kol.id) rescue nil
    @share_url ||= "#{Rails.application.secrets.domain}/campaign_visit?campaign_id=#{campaign.id}" rescue ''
    Rails.logger.wechat_kol_campaign.info "--campaign_details: @share_url #{@share_url}"
    @app_download_url = Rails.application.secrets[:download_url]
    render :layout => false
  end 

  private

  def valid_request?
    # key = "RANDOM_KEY"
    # data = "id=#{params[:id]}&channel_id=#{params[:channel_id]}&cid=#{params[:cid]}&nonce=#{params[:nonce]}&timestamp=#{params[:timestamp]}"
    # digest = OpenSSL::Digest.new('sha1')
    # hmac = OpenSSL::HMAC.hexdigest(digest, key, data)
    # @campaign = Campaign.find(params[:campaign_id]) rescue nil
    # unless hmac == params[:signature] || @campaign.present?
    #   Rails.logger.wechat_kol_campaign.info "--check-error: #{params}"
    #   render text: "error", status: "422" and return
    # end
    @campaign = Campaign.find(params[:campaign_id]) rescue nil
    unless  @campaign.present?
      Rails.logger.wechat_kol_campaign.info "--check-error: #{params}"
      render text: "error", status: "422" and return
    end
  end
end