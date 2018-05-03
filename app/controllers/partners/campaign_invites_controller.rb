class Partners::CampaignInvitesController < Partners::BaseController
	before_filter :get_campaign_invite, except: [:index]

	def index
		@campaign_invites = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where("screenshot is not NULL")

		@q = @campaign_invites.ransack({kol_admintags_tag_eq: @admintag.tag})

    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)
	end

	def shows
		@campaign_shows = CampaignShow.where(kol_id: @campaign_invite.kol_id, campaign_id: @campaign_invite.campaign_id).
											order('created_at DESC').paginate(paginate_params)
	end

	private

	def get_campaign_invite
		@campaign_invite = CampaignInvite.find(params[:campaign_invite_id])
	end

end
