class Partners::KolsController < Partners::BaseController

	def index
		@kols = admintag.kols.order('created_at DESC').paginate(paginate_params)
	end

end