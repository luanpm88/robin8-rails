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
          # optional :gender,               type: Integer
          # optional :kol_role,             type: String, values: %w(public big_v creator), default: 'public'
          # optional :age,									type: String
          # optional :industry,             type: String
          # optional :circle_ids,           type: Array[Integer], coerce_with: ->(val) { val.split(/\s+/).map(&:to_i) }
          # optional :wechat_firends_count, type: Integer
        end
        post 'base_info' do
        	current_kol.gender 								= params[:gender] 							if params[:gender]
        	current_kol.age    								= params[:age]    							if params[:age]
        	current_kol.industry 							= params[:industry] 						if params[:industry]
        	current_kol.wechat_firends_count 	= params[:wechat_firends_count] if params[:wechat_firends_count]
        	current_kol.role_apply_status     = 'applying'                    if params[:kol_role] != 'public'
 
        	current_kol.save

        	select_circles = Circle.where(id: params[:circle_ids])

        	if @select_circles.present?
        		current_kol.circles.delete_all
        		current_kol.circles << @select_circles
        	end
        end

      end
    end
  end
end