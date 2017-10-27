# coding: utf-8
module GeometryApi
    class V1 < Grape::API
      prefix :api
      format :json

      # params do
      # 	requires :token , type: String
      # end
	  get :geometry_users do 
	  	return error!('401 Unauthorized', 401) unless params[:token]
	  	if params[:token] == "aOzeCuIjKLqb"
	      kol = Admintag.find_by(tag: "Geometry").kols
	      present :error , 0
	      present :count , kol.count
	      present :users , kol , with: GeometryApi::Entities::KolEntities::Summary
	    else
	      present :error , 403
	    end
	  end
	end
end