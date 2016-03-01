module API
  module V1
    class Cities < Grape::API
      resources :cities do
        get '/' do
          cities = City.all
          present :error, 0
          present :cities, cities, with: API::V1::Entities::CityEntities::Summary
        end

      end
    end
  end
end
