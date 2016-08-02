module Brand
  module V1
    class KolsAPI < Base
      group do
        before do
          # authenticate!
        end

        resource :kols do

          desc 'Search kols with conditions and return kols list'
          params do
            optional :region, type: String
          end
          get "search" do
            @kols = Kol.all

            if params[:region] and params[:region] != "全部"
              regions = params[:region].split(",").reject(&:blank?)
              cities = City.where(name: regions).map(&:name_en)

              @kols = @kols.where(app_city: cities)
            end

            if params[:profession] and params[:profession] != "全部"
              profession_params = params[:profession].split(",").reject(&:blank?)
              professions = Profession.where(name: profession_params).map(&:id)

              @kols = @kols.joins("INNER JOIN `kol_professions` ON `kols`.`id` = `kol_professions`.`kol_id`")
                           .where("`kol_professions`.`profession_id` IN (?)", professions)
            end

            if params[:sns] and params[:sns] != "全部"
              sns_params = params[:sns].split(",").reject(&:blank?)
              sns = sns_params & ["qq", "weibo", "wechat"]
              
            end

            if params[:price_range] and params[:price_range] != "全部"
              min_price, max_price = params[:price_range].split(",").map(&:to_i)
              if min_price >= 0 and max_price > min_price
                
              end
            end

            @kols = @kols.page(params[:page]).per_page(6)

            {
              items: @kols,
              paginate: {
                "X-Page": @kols.current_page,
                "X-Total-Pages": @kols.total_pages
              }
            }
          end
        end
      end
    end
  end
end