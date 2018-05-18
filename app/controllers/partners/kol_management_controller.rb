class Partners::KolManagementController < Partners::BaseController
	
	def index
		# @aa    = Kol.joins(:admintags).where("admintags.tag=?", @admintag.tag).ransack(params[:q])
#    @q = Kol.joins(:admintags).where("admintags.tag=?", @admintag.tag).ransack(params[:q])
#    @kols = @q.result.order('id DESC')
    @test = Kol.first
#    respond_to do |format|
#      format.html do
#        @kols = @kols.paginate(paginate_params)
#        render 'index'
#      end
#    end
	end
  
  def kol
    logger.info "Processing the request..."
#    60081 > 62595 > 62994 > 63271
    @kol = Kol.find(63274)
  end
end