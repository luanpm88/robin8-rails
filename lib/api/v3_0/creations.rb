# coding: utf-8
module API
  module V3_0
    class Creations < Grape::API
      resources :creations do
        before do
          # authenticate!
        end

        #get creations list
        params do
        	optional :status, type: String
          optional :page,   type: Integer
        end
        get '/' do
        	list = 	if %w(passed ended finished).include?(params[:status])
        						Creation.by_status(params[:status])
        					else
        						Creation.alive
        					end

        	list =  list.page(params[:page]).per_page(10)

        	present :error, 0
        	present :list,  list, with: API::V3_0::Entities::CreationEntities::BaseInfo
        end

        # get simple creation detail
        params do
        	requires :id, type: Integer
        end
        get ':id' do
        	creation = Creation.find_by(params[:id])

        	error_403!(detail: 'not found') unless creation.try(:is_alive?)

        	present :error,    0
        	present :creation, creation, with: API::V3_0::Entities::CreationEntities::Detail
        end

      end
    end
  end
end