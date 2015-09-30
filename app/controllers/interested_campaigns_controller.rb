class InterestedCampaignsController < InheritedResources::Base

  def ask_for_invite
    interested_campaign = []
    unless params[:interested_campaign_id].blank?
      campaign = Campaign.find(params[:interested_campaign_id])
      user = User.find(campaign.user_id)
      interested = InterestedCampaign.new
      interested.kol_id = current_kol.id
      interested.user_id = user.id
      interested.campaign_id = params[:interested_campaign_id]
      interested.save
      #KolMailer.campaign_invite(kol,user,campaign).deliver
    end
    render json: interested_campaign
  end

  def update
    interested_campaign = []
    unless params[:interested_campaign_id].blank?
      interested_campaign = InterestedCampaign.find(params[:interested_campaign_id])
    end
    unless interested_campaign.blank?
      interested_campaign.status = params[:status]
      interested_campaign.save!
      if params[:status] == 'I'
        kol = Kol.find(interested_campaign.kol_id)
        campaign = Campaign.find(interested_campaign.campaign_id)
        user = User.find(interested_campaign.user_id)
        invite = CampaignInvite.new
        invite.kol = kol
        invite.status = ''
        invite.campaign = campaign
        invite.save
        interested_campaign.delete
        KolMailer.campaign_invite(kol,user,campaign).deliver
      end
    end
    render json: interested_campaign
  end

end
