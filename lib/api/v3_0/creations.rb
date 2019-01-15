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
          optional :page, type: Integer
        end
        get '/' do

        	present errors: 0
        	present list: {}
        end

        params do
        	requires :id, type: Integer
        end
        get ':id' do
        	present errors: 0
        	present creation: {}
        end

      end
    end
  end
end