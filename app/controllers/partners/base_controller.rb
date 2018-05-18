class Partners::BaseController < ApplicationController

  layout 'partners'

	before_action :admintag


	private

  def paginate_params
    {
      page: 		params[:page] || 1,
      per_page: params[:per_page] || 20
    }
  end
  def kol_params
    {
      id: params[:id] || 0
    }
  end
	def admintag
    # $redis.set 'geometry', 'geometry2018' # set this to redis
		@admintag = Admintag.find_by_tag session[:admin_tag]
    
    redirect_to partners_sign_in_path unless @admintag
	end

end