class MarketingDashboard::CampaignsController < ApplicationController
  layout 'admin'

  def index
    @campaigns = Campaign.paginate(:page => 1, :per_page => 20)
  end
end
