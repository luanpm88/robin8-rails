# coding: utf-8
module API
  module V2_1
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        desc 'update kol base info'
        params do
          # optional :gender,               type: Integer, values: [1, 2]
          # optional :kol_role,             type: String, values: %w(public big_v creator), default: 'public'
          # optional :age,									type: String
          # optional :industry,             type: String
          # optional :circle_ids,           type: Array[Integer]
          # optional :wechat_firends_count, type: Integer
        end
        post 'base_info' do
        	current_kol.gender 								= params[:gender] 							if params[:gender]
        	current_kol.age    								= params[:age]    							if params[:age]
        	current_kol.industry 							= params[:industry] 						if params[:industry]
        	current_kol.wechat_firends_count 	= params[:wechat_firends_count] if params[:wechat_firends_count]
        	current_kol.kol_role              = params[:kol_role]             if params[:kol_role]
        	current_kol.role_apply_status     = 'applying'                    if params[:kol_role] != 'public'
 
        	current_kol.save

        	if current_kol.circle_ids - Array(params[:circle_ids]) != []
	        	select_circles = Circle.where(id: params[:circle_ids])
	        	if select_circles.present?
	        		current_kol.circles.delete_all
	        		current_kol.circles << select_circles
	        	end
	        end

	        present :error, 0
        end

        desc 'applying creator'
        params do
        	requires :circle_ids,   type: Array[Integer]
        	requires :terrace_ids, 	type: Array[Integer]
        	requires :price, 				type: Float
        	requires :fans_count, 	type: Integer
        	requires :gender, 			type: Integer, values: [1, 2]
        	requires :age_range, 	  type: Integer
        	requires :cities, 		  type: Array[String]
        	requires :content_show, type: String
        	optional :remark, 			type: String
        end
        post 'applying_creator' do
        	creator = current_kol.creator ? current_kol.creator : current_kol.creator.new

        	creator.price 				= params[:price]
        	creator.fans_count 		= params[:fans_count]
        	creator.gender 				= params[:gender]
        	creator.age_range 		= params[:age_range]
        	creator.content_show 	= params[:content_show]
        	creator.remark 				= params[:remark]

        	creator.save

        	if creator.circle_ids - params[:circle_ids] != []
	        	select_circles = Circle.where(id: params[:circle_ids])
	        	if select_circles.present?
	        		creator.circles.delete_all
	        		creator.circles << select_circles
	        	end
	        end

	        if creator.terrace_ids - params[:terrace_ids] != []
	        	select_terraces = Terrace.where(id: params[:terrace_ids])
	        	if select_terraces.present?
	        		creator.terraces.delete_all
	        		creator.terraces << select_terraces
	        	end
	        end

	        if creator.cities.map(&:name) - params[:cities] != []
	        	select_cities = City.where(name: params[:cities])
	        	if select_cities.present?
	        		creator.cities.delete_all
	        		creator.cities << select_cities
	        	end
	        end

	        present :error, 0
        end

      end
    end
  end
end