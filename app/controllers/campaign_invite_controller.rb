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
    invite = CampaignInvite.find params[:id]
    invite_params = params.require(:campaign_invite).permit(:screenshot)

    if invite.screenshot.present?
      invite.reupload_screenshot invite_params[:screenshot]
    else
      invite.update_attributes invite_params
    end

    render :json => invite
  end

  def mark_as_running
    @kol = current_kol
    return render :json => {error: 'no available kol!'} if @kol.blank?

    @campaign_invite = CampaignInvite.find params[:id]

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
             when 'verify'
               'verify'
             else
               'error'
             end

    return render :json => {error: 'error type!'} if status.eql?('error')

    if status.eql? 'verify'
      campaigns_by_status = @kol.campaign_invites.where(status: 'finished').where.not(img_status: 'passed').joins(:campaign).where('campaign_invites.avail_click > 0 AND campaigns.deadline > ?', Time.now - 7.days).order('updated_at desc')
    elsif status.eql? 'finished'
      campaigns_by_status = @kol.campaign_invites.where(status: 'finished', img_status: 'passed').order('created_at desc')
    else
      campaigns_by_status = @kol.campaign_invites.where(status: status).order('created_at desc')
    end

    limit = params[:limit] || 3
    offset = params[:offset] || 0
    campaign_invites_by_limit_and_offset = campaigns_by_status.drop(offset.to_i).first(limit.to_i)

    render json: campaign_invites_by_limit_and_offset, each_serializer: CampaignInviteSerializer
  end

  def change_img_status
    campaign_invite_id = params[:id]
    @campaign_invite = CampaignInvite.find campaign_invite_id
    mobile_number = @campaign_invite.kol.mobile_number
    if params[:status] == "agree"
      @campaign_invite.screenshot_pass
      if @campaign_invite.img_status == 'passed'
        return render json: { result: 'agree' }
      else
        return render json: { result: 'error' }
      end
    end
    if params[:status] == "reject"
      @campaign_invite.screenshot_reject
      if @campaign_invite.img_status == 'rejected'
        sms_client = YunPian::SendCampaignInviteResultSms.new(mobile_number, params[:status])
        res = sms_client.send_reject_sms
        return render json: { result: 'reject' }
      else
        return render json: { result: 'error' }
      end
    end
    return render json: { result: 'error' }
  end

  def change_multi_img_status
    ids = params[:ids]
    @campaign_invites = CampaignInvite.find ids

    if params[:status] == "agree"
      @campaign_invites.each { |c| c.screenshot_pass }
      return render json: { result: 'agree' }
    end

    if params[:status] == "reject"
      mobile_numbers = []
      @campaign_invites.each do |c|
        c.screenshot_reject
        mobile_numbers << c.kol.mobile_number
      end

      CampaignInviteSmsWorker.perform_async(mobile_numbers, params[:status])
      return render json: { result: 'reject' }
    end
    return render json: { result: 'error' }

  end
end
