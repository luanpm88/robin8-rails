module API
  module V1
    class Messages < Grape::API
      resources :messages do
        before do
          authenticate!
        end

        get '/' do
          cities = City.all
          present :error, 0
          present :cities, cities, with: API::V1::Entities::CityEntities::Summary
        end

        put 'read' do

        end

      end
    end
  end
end
