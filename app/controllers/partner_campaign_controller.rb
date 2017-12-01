class PartnerCampaignController < ApplicationController
  before_action :valid_signature?
  layout :false
  
  def campaign
    Rails.logger.partner_campaign.info "--checked: #{params}"
    kol = Kol.find_or_create_by(channel: params.require(:channel_id),
                                cid:     params.require(:cid))

    kol.update_attributes!(avatar_url: params[:images],
                           name:       params[:nickname])

    kol.add_campaign_id  params[:id]
    kol.approve_campaign params[:id]
    @campaign_invite = @campaign.get_campaign_invite(kol.id) rescue nil
    if @campaign_invite
      campaign_invite_uuid = @campaign_invite.uuid
      Rails.logger.partner_campaign.info "--campaign_details: campaign_invite_uuid #{campaign_invite_uuid}"
      @share_url = @campaign_invite.visit_url if campaign_invite_uuid
      Rails.logger.partner_campaign.info "--campaign_details: @share_url #{@share_url}"
    end
    @share_url ||= "#{Rails.application.secrets.domain}/campaign_visit?campaign_id=#{@campaign.id}" rescue ''
    Rails.logger.partner_campaign.info "--campaign_details: @share_url #{@share_url}"
    respond_to do |format|
      format.html

      format.json do
        render :json => {click: @campaign_invite.get_avail_click(true) , earn_money: @campaign_invite.earn_money , share_url: @share_url}.to_json
      end
    end
  end

  def index
      campaign = Campaign.where(channel: ['all' , params[:channel_id]]).order(updated_at: :desc).select(:id , :name , :per_action_budget ,:description , :remark ,:img_url).map {|t|  t }
      render json: {status: '200' , campaign: campaign}.to_json
  end

  def show
    render json: {status: '200' , campaign: {id: @campaign.id , name: @campaign.name , per_action_budget: @campaign.per_action_budget , description: @campaign.description ,remark: @campaign.remark ,img_url: @campaign.img_url ,  balance: @campaign.remain_budget }}.to_json
  end

  private

  def valid_signature?
    # return true unless params[:channel_id] == "wcs" # WCS 微差事加密而已
    if params[:channel_id] == "wcs"
      key       = "k4B9Uif81T3Y"
      data      = "id=#{params[:campaign_id] || params[:id]}&channel_id=#{params[:channel_id]}&cid=#{params[:cid]}&nonce=#{params[:nonce]}&timestamp=#{params[:timestamp]}"
      digest    = OpenSSL::Digest.new('sha1')
      hmac      = OpenSSL::HMAC.hexdigest(digest, key, data)  
      unless hmac == params[:signature]
        Rails.logger.partner_campaign.info "--check-error: #{params}"
        render text: "error", status: "422" and return
      end
    end
    @campaign = Campaign.find_by(id: (params[:campaign_id] || params[:id]) , channel: ['all' , params[:channel_id]]) rescue nil
    if @campaign.nil?
      Rails.logger.partner_campaign.info "--can't find campaign: #{params}"
      render text: "error", status: "422" and return
    else
      @campaign
    end
  end
end
