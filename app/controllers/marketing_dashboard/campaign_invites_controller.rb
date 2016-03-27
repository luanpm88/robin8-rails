class MarketingDashboard::CampaignInvitesController < MarketingDashboard::BaseController
  def index
    @campaign_invites = CampaignInvite.where.not(:screenshot => '').paginate(paginate_params)
  end
end
