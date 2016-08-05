module Brand
  module V1
    class KolsAPI < Base
      helpers do
        def join_table(name)
          @join_state ||= {
            social_accounts: false,
            kol_professions: false
          }

          unless @join_state[name]
            @kols = @kols.joins("INNER JOIN `#{name}` ON `kols`.`id` = `#{name}`.`kol_id`")
            @join_state[name] = true
          end
        end
      end

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

              join_table(:kol_professions)
              @kols = @kols.where("`kol_professions`.`profession_id` IN (?)", professions)
            end
            if params[:sns] and params[:sns] != "全部"
              sns_params = params[:sns].split(",").reject(&:blank?)
              sns = sns_params & ["public_wechat", "weibo", "meipai", "miaopai"]

              join_table(:social_accounts)
              @kols = @kols.where("`social_accounts`.`provider` IN (?)", sns)
            end

            if params[:price_range] and params[:price_range] != "全部"
              min_price, max_price = params[:price_range].split(",").map(&:to_i)
              if min_price >= 0 and max_price > min_price

                join_table(:social_accounts)
                @kols = @kols.where("`social_accounts`.`price` BETWEEN ? AND ?", min_price, max_price)
              end
            end

            if params[:just_count]
              { count: @kols.count }
            else
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
end
