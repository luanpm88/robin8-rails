class Partners::KolsController < Partners::BaseController
	before_filter :get_kol, except: [:index]

	def index
		@kols = admintag.kols
		@q    = @kols.includes(:admintags).ransack(params[:q])
    @kols = @q.result.order('id DESC').paginate(paginate_params)
	end

	def activities
    @campaigns = @kol.campaigns.paginate(paginate_params)
	end

	def shows
		@campaign_shows = @kol.campaign_shows.paginate(paginate_params)
	end

	def capital_flow_sheet
		@transactions = Transaction.where(account: @kol).order('id DESC').paginate(paginate_params)
	end

	private

	def get_kol
		@kol = Kol.find(params[:id])
	end

end