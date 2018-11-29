class MarketingDashboard::VoterShipsController <  MarketingDashboard::BaseController
  def index
    kol = Kol.find params[:kol_id]
    @voter_ships = kol.voter_ships.order('count desc').paginate(paginate_params)
  end
end
