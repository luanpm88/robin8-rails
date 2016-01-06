class CampaignInviteController < ApplicationController
  def index
    someone = current_user
    someone = current_kol if someone.nil?
    invites = someone.nil? ? [] : someone.campaign_invites.joins("RIGHT JOIN campaigns ON campaign_invites.campaign_id = campaigns.id").where("campaigns.deadline > ? and (campaign_invites.status IS NULL or campaign_invites.status='')", Time.zone.now.beginning_of_day)
    render json: invites, each_serializer: CampaignInviteSerializer
  end

  def create
  end

  def update
    invite = []
    unless params[:campaign_id].blank?
      invite = CampaignInvite.where(:campaign_id => params[:campaign_id], :kol_id=>current_kol.id)
      invite = invite.first
    else
      invite = CampaignInvite.find(params[:id])
    end
    if invite.kol != current_kol
      render json: {errors: {permission_denied: 'You must be authorized'}}, :status => :unauthorized
    else
      invite.status = params[:status]
      if params[:status] == "D"
        invite.decline_date = DateTime.now()
      end
      invite.save
      if params[:status] == "A"
        a = Article.new(kol_id: current_kol.id, campaign_id: invite.campaign.id)
        a.save
      end
      render json: invite
    end
  end

  def mark_as_running
    @kol = current_kol
    return render :json => {error: 'no available kol!'} if @kol.blank?

    @campaign_invite = CampaignInvite.where(kol_id: @kol.id, campaign_id: params[:campaign_id]).first

    return render :json => {status: 'needMobile'} unless @kol.mobile_number.present?

    if @campaign_invite.status.eql? 'running'
      @campaign_invite.update_attributes({status: 'approved', approved_at: Time.now})
    end

    return render :json => {status: 'ok'}

  end

  def interface
    @kol = current_kol

    return render :json => {error: 'no available kol!'} if @kol.blank?

    status = case params[:type]
             when 'upcoming'
               'running'
             when 'running'
               'approved'
             when 'complete'
               'finished'
             else
               'error'
             end

    return render :json => {error: 'error type!'} if status.eql?('error')

    campaigns_by_status = @kol.campaign_invites.where(status: status).order('created_at desc')

    # TODO refactor: use serializer simpify code
    limit = params[:limit] || 3
    offset = params[:offset] || 0
    campaign_invites_by_limit_and_offset = campaigns_by_status.limit(limit).offset(offset)
    result = campaign_invites_by_limit_and_offset.map do |x|
      obj = x.campaign.attributes
      obj['budget'] = obj['budget'].round(2)
      obj['per_click_budget'] = obj['per_click_budget'].round(2)
      obj['campaign_invite_id'] = x.id
      obj['status'] = x.status
      unless x.share_url.present?
        x.generate_uuid_and_share_url
      end
      obj['share_url'] = x.share_url
      obj['remain_budget'] = x.campaign.remain_budget
      obj['avail_click'] = x.get_avail_click
      obj['img_url'] = ActionController::Base.helpers.asset_path('campaign_default_img.png') unless obj['img_url'].present?
      obj
    end

    return render :json => result
  end
end
