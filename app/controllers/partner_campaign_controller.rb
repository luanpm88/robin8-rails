class PartnerCampaignController < ApplicationController
  before_action :valid_signature? , :set_kol
  before_action :set_campaign, only: [:campaign, :show]
  layout :false

  def campaign
    Rails.logger.partner_campaign.info "--checked: #{params}"
    @campaign_invite , @share_url = @campaign.create_share_url(@kol)
    respond_to do |format|
      format.html
      format.json do
        render :json => {click: @campaign_invite.get_avail_click(true) , earn_money: @campaign_invite.earn_money , share_url: @share_url}.to_json
      end
    end
  end

  def index
    json = Array.new
    campaigns = Campaign.where(channel: ['all' , params.require(:channel_id)]).order(updated_at: :desc)
    if campaigns.present?
      campaigns.each do |campaign|
        campaign_invite , share_url = campaign.create_share_url(@kol)
        json.push({id: campaign.id , name: campaign.name ,status: campaign.status ,  per_action_budget: campaign.actual_per_action_budget ,   balance: campaign.remain_budget , description: campaign.description ,remark: campaign.remark ,img_url: campaign.img_url ,  balance: campaign.remain_budget ,click: campaign_invite.get_avail_click(true) , earn_money: campaign_invite.earn_money , share_url: share_url})
      end
    end
    render json: {status: '200' , campaigns: json}.to_json
  end

  def show
    campaign_invite , share_url = @campaign.create_share_url(@kol)
    render json: {status: '200' , campaign: {id: @campaign.id , name: @campaign.name , status: @campaign.status ,per_action_budget: @campaign.actual_per_action_budget , balance: @campaign.remain_budget ,description: @campaign.description ,remark: @campaign.remark ,img_url: @campaign.img_url ,click: campaign_invite.get_avail_click(true) , earn_money: campaign_invite.earn_money , share_url: share_url }}.to_json
  end

  private

  def valid_signature?
    if params[:channel_id] == "wcs"
      key       = "k4B9Uif81T3Y"
      data      = "id=#{params[:id]||'0'}&channel_id=#{params[:channel_id]}&cid=#{params[:cid]}&nonce=#{params[:nonce]}&timestamp=#{params[:timestamp]}"
      digest    = OpenSSL::Digest.new('sha1')
      hmac      = OpenSSL::HMAC.hexdigest(digest, key, data)
      unless hmac == params[:signature]
        Rails.logger.partner_campaign.info "--check-error: #{params}"
        render text: "Params error", status: "422" and return
      end
    end
  end

  def set_campaign
    @campaign = Campaign.find_by(id: params[:id], channel: ['all' , params[:channel_id]]) rescue nil
    if @campaign.nil?
      Rails.logger.partner_campaign.info "--can't find campaign: #{params}"
      render text: "Params error", status: "422" and return
    end
  end

  def set_kol
    @kol = Kol.find_or_create_by(channel: params.require(:channel_id),
                                cid:     params.require(:cid))

    @kol.update_attributes!(avatar_url: params[:images],
                           name:       params[:nickname])
  end
end
