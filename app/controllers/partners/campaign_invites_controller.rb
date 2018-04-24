class Partners::CampaignInvitesController < Partners::BaseController

	def index
		@campaign_invites = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where("screenshot is not NULL")

		@q = @campaign_invites.ransack({"kol_admintags_tag_eq"=>"Geometry"})

    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)
	end
end
