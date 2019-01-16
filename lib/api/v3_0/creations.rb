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

        	list = Creation.all

        	present :errors, 0
        	present :list, list, with: API::V3_0::Entities::CreationEntities::BaseInfo
        end

        params do
        	requires :id, type: Integer
        end

        get ':id' do
        	creation = Creation.find_by params[:id]

        	error_403!(detail: 'not found') unless creation
        	present :errors, 0
        	present :creation, creation
        end

      end
    end
  end
end