class Partners::KolsController < Partners::BaseController
	before_filter :get_kol, except: [:index]

	def index
		@q    = Kol.joins(:admintags).where("admintags.tag=?", @admintag.tag).ransack(params[:q])
    @kols = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @kols = @kols.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"KOL记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
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