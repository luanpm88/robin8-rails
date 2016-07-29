module Brand
  module V1
    class KolsAPI < Base
      include Grape::Kaminari

      group do
        before do
          # authenticate!
        end

        resource :kols do

          desc 'Search kols with conditions and return kols list'
          paginate per_page: 10
          params do
            optional :region, type: String
          end
          get "search" do
            @kols = Kol.all
            if params[:region] and params[:region] != "全部"
              regions = params[:region].split("/").reject(&:blank?)
              cities = City.where(name: regions).map(&:name_en)
              @kols = @kols.where(app_city: cities)
            end

            @kols = @kols.page(params[:page]).per(10)
            paginate(@kols)
            present @kols
          end
        end
      end
    end
  end
end