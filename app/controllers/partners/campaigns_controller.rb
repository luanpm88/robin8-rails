class Partners::CampaignsController < Partners::BaseController

	def index
		@campaigns = Campaign.joins(kols: :admintags).where("admintags.tag=?", @admintag.tag).order(created_at: :desc).uniq(:id).paginate(paginate_params)
	end

end
