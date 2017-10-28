# coding: utf-8
module GeometryApi
  class V1 < Grape::API
    prefix :api
    format :json

    params do
      requires :token , type: String
    end

	  get :geometry_users do
	  	if params[:token] == "aOzeCuIjKLqb"
        kols = Admintag.find_by(tag: "Geometry").kols rescue []
	      present :error , 0
	      present :count , kols.count
	      present :users , kols , with: GeometryApi::Entities::KolEntities::Summary
	    else
        error!('401 Unauthorized', 401)
	    end
	  end
	end
end
