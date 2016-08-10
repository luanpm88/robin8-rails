module Brand
  module V1
    class KolsAPI < Base
      helpers do
        def join_table(name)
          @join_state ||= {
            social_accounts: false,
            kol_tags: false
          }

          unless @join_state[name]
            @kols = @kols.joins("INNER JOIN `#{name}` ON `kols`.`id` = `#{name}`.`kol_id`")
            @join_state[name] = true
          end
        end
      end

      group do
        before do
          authenticate!
        end

        resource :kols do

          desc 'Search kols with conditions and return kols list'
          params do
            optional :region, type: String
          end
          get "search" do
            @kols = Kol.active.big_v

            if params[:region] and params[:region] != "全部"
              regions = params[:region].split(",").reject(&:blank?)
              cities = City.where(name: regions).map(&:name_en)

              @kols = @kols.where(app_city: cities)
            end

            if params[:tag] and params[:tag] != "全部"
              tag_params = params[:tag].split(",").reject(&:blank?)
              tags = Tag.where(name: tag_params).map(&:id)

              join_table(:kol_tags)
              @kols = @kols.where("`kol_tags`.`tag_id` IN (?)", tags)
            end

            if params[:sns] and params[:sns] != "全部"
              sns_params = params[:sns].split(",").reject(&:blank?)
              sns = sns_params & ["wechat"]

              join_table(:social_accounts)
              @kols = @kols.where("`social_accounts`.`provider` IN (?)", sns)
            end

            if params[:just_count]
              { count: @kols.distinct.count }
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
