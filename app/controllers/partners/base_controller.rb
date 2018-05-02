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

	def admintag
    # $redis.set 'geometry', 'geometry2018'
		@admintag = Admintag.find_by_tag session[:admin_tag]
	end

end