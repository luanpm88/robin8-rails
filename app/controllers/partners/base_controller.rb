class Partners::BaseController < ApplicationController
	before_action :admintag


	private

  def paginate_params
    {
      page: 		params[:page] || 1,
      per_page: params[:per_page] || 20
    }
  end

	def admintag
		@admintag = Admintag.find_by_tag 'Geometry'
	end

end