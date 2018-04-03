require 'rqrcode'

class PartnerCampaignController < ApplicationController
  before_action :valid_signature? , :set_kol, except: [:complete]
  before_action :set_campaign, only: [:campaign, :show]
  layout :false

  def campaign
    Rails.logger.partner_campaign.info "--checked: #{params}"
    @campaign_invite , @share_url = @campaign.create_share_url(@kol)
    respond_to do |format|
      format.html do
        p = request.params.except("action","controller")
        p["t"] = Time.now.to_i.to_s
        @refresh_url = "http://"+request.host+request.path+"?"+p.to_query
      end
      format.json do # For WCS 微差事
        render :json => {click: @campaign_invite.get_avail_click(true) , earn_money: @campaign_invite.earn_money , share_url: @share_url}.to_json
      end
    end
  end

  def index # For WCS 微差事
    json = Array.new
    campaigns = Campaign.where(channel: ['all' , params.require(:channel_id)]).order(updated_at: :desc)
    if campaigns.present?
      campaigns.each do |campaign|
        campaign_invite , share_url = campaign.create_share_url(@kol)
        json.push({id: campaign.id , name: campaign.name ,status: campaign.status , per_action_budget: campaign.actual_per_action_budget ,   balance: campaign.remain_budget , description: campaign.description ,remark: campaign.remark ,img_url: campaign.img_url , click: campaign_invite.get_avail_click(true) , earn_money: campaign_invite.earn_money , share_url: share_url})
      end
    end
    render json: {status: '200' , campaigns: json}.to_json
  end

  def show # For WCS 微差事
    campaign_invite , share_url = @campaign.create_share_url(@kol)
    render json: {status: '200' , campaign: {id: @campaign.id , name: @campaign.name , status: @campaign.status ,per_action_budget: @campaign.actual_per_action_budget , balance: @campaign.remain_budget ,description: @campaign.description ,remark: @campaign.remark ,img_url: @campaign.img_url ,click: campaign_invite.get_avail_click(true) , earn_money: campaign_invite.earn_money , share_url: share_url }}.to_json
  end

  def complete # For AZB 阿里众包
    if Kol.find_by(id: params.require(:kol_id), channel: "azb") && Campaign.find_by(id: params.require(:campaign_id))
      if CampaignInvite.find_by(kol_id: params[:kol_id], campaign_id: params[:campaign_id]).
        update_attributes!(azb_shared: true)
        AlizhongbaoCompleteShareWorker.perform_async(params[:kol_id], params[:campaign_id])
        render json: {status: '200'}.to_json and return
      end
    end
    render json: {status: '422'}
  end

  private

  def valid_signature?
    if params.require(:channel_id) == "wcs"
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
    cid = case params[:channel_id]
          when "wcs"
            params.require(:cid)
          when "azb"
            params.require(:userId)
          end

    @kol = Kol.find_or_create_by(channel: params.require(:channel_id),
                                 cid:     cid)

    if $redis.lpop("dope_sample_data").nil?
      Partners::Alizhongbao.import_dope_data("#{Rails.root}/doc/ali_kol_nickname_and_avatar.csv")
    end
    avatar_url = if params[:images].present?
                   params[:images]
                 elsif @kol.avatar_url.blank?
                   sample_data ||= eval($redis.lpop("dope_sample_data"))
                   sample_data[0]
                 else
                   @kol.avatar_url
                 end

    nickname   = if params[:nickname].present?
                   params[:nickname]
                 elsif @kol.name.blank?
                   sample_data ||= eval($redis.lpop("dope_sample_data"))
                   sample_data[1].gsub("'","")
                 else
                   @kol.name
                 end

    @kol.update_attributes!(avatar_url: avatar_url,
                            name:       nickname)
  end
end
