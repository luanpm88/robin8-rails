module Property
  module V1
    class Provinces < Base
      include Property::V1::Helpers

      resource :provinces do
        get '/' do
          province_list = {}

          Province.all.map {|i| province_list[i.name] = i.id }
          present province_list
        end

        params do
          requires :province_id, type: Integer
        end
        get '/cities' do
          cities = Province.find(params[:province_id]).cities
          present cities.map {|i| i.name } #cities, with: Property::V1::Entities::Cities
        end
      end

    end
  end
end
