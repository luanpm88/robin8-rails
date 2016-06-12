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
    return render :json => { error: 'no available kol!' } if current_kol.blank?
    return render :json => { status: 'needMobile' } unless current_kol.mobile_number.present?

    campaign = Campaign.find params[:id]

    if campaign.need_finish
      CampaignWorker.perform_async campaign.id, 'fee_end'
      return render :json => { status: 'campaign finished' }
    end

    if current_kol.approve_campaign(campaign.id).is_a? CampaignInvite
      return render :json => { status: 'ok' }
    else
      return render :json => { status: 'error' }
    end
  end

  def interface
    return render :json => { error: 'no available kol!' } if current_kol.blank?

    limit = params[:limit] || 3
    offset = params[:offset] || 0

    # todo refactor this return campaign should not in campaign_invites controller
    if params[:type].eql? 'upcoming' or params[:type].eql? 'missed'
      campaigns = case params[:type]
                  when 'upcoming'
                    current_kol.running_campaigns
                  when 'missed'
                    current_kol.missed_campaigns
                  end
      return render :json => campaigns.offset(offset.to_i).limit(limit.to_i), :each_serializer => CampaignsSerializer
    end

    campaign_invites_by_type = case params[:type]
                               when 'running'
                                 current_kol.campaign_invites.approved
                               when 'complete'
                                 current_kol.campaign_invites.completed
                               when 'verify'
                                 current_kol.campaign_invites.verifying
                               else
                                 return render :json => { error: 'error type!' }
                               end

    campaign_invites_by_paged = campaign_invites_by_type.offset(offset.to_i).limit(limit.to_i)

    render :json => campaign_invites_by_paged, :each_serializer => CampaignInviteSerializer
  end

  def find_by_kol_and_campaign
    # todo this line appear too many times
    return render :json => { error: 'no available kol!' } if current_kol.blank?

    campaign = Campaign.find params[:campaign_id]

    campaign_invite = CampaignInvite.where(:kol => current_kol, :campaign => campaign).first

    return render :json => campaign_invite, :serizlizer => CampaignInviteSerializer
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
        # sms_client = YunPian::SendCampaignInviteResultSms.new(mobile_number, params[:status])
        # res = sms_client.send_reject_sms
        return render json: { result: 'reject' }
      else
        return render json: { result: 'error' }
      end
    end
    return render json: { result: 'error' }
  end

  def change_multi_img_status
    ids = params[:ids]

    @campaign_invites = CampaignInvite.where :id => ids
    if params[:status] == "agree"
      @campaign_invites.each { |c| c.screenshot_pass }
      return render json: { result: 'agree' }
    end


    if params[:status] == "reject"
      Rails.logger.alipay.info "-------- params[:status] == 'reject' --------------"
      if params[:reject_reason].present?
        reject_reason = params[:reject_reason]
      else
        reject_reason = params[:common_reject_reason]
      end
      @campaign_invites.each do |c|
        c.screenshot_reject reject_reason
        Rails.logger.alipay.info "-------- @campaign_invites.each --------------"
      end

      Rails.logger.alipay.info "-------- before json: { result: 'reject' } --------------"
      return render json: { result: 'reject' }
    end
    return render json: { result: 'error' }
  end
end
