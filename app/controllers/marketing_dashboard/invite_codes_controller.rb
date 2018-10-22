class MarketingDashboard::InviteCodesController < MarketingDashboard::BaseController
  before_action :find_invite_code , only: [:destroy]

  def index
  	@invite_codes = if params[:type]
  		                InviteCode.where(invite_type: params[:type])
  		              else
  	                  InviteCode.all
  	                end

  	@q = @invite_codes.ransack(params[:q])

  	@invite_codes = @q.result.paginate(paginate_params)
  end

  def new
    @invite_code = InviteCode.new
  end

  def create
	  @invite_code = InviteCode.new(params[:invite_code].permit!)
	  
    if @invite_code.save
      redirect_to :action => :index
	  else
	    render :action => :new
	  end
  end

  def edit
  	@invite_code = InviteCode.find params[:id]
  end

  def update
  	@invite_code = InviteCode.find params[:id]

  	if @invite_code.update(params[:invite_code].permit!)
      redirect_to :action => :index
  	else
  	  render :action => :edit
  	end
  end

  private

  def find_invite_code
  	@invite_code = InviteCode.find params[:id]
  end

end
 