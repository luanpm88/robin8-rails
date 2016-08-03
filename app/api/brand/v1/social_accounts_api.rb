module Brand
  module V1
    class SocialAccountsAPI < Base
      helpers do
        def join_table(name)
          @join_state ||= {
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

        resource :social_accounts do

          desc 'Search social accounts with conditions and return accounts list'
          params do
            optional :region, type: String
            optional :profession, type: String
            optional :sns, type: String
            optional :price_range, type: String
          end
          get "search" do
            @social_accounts = SocialAccount.all

            if params[:region] and params[:region] != "全部"
              regions = params[:region].split(",").reject(&:blank?)
              cities = City.where(name: regions).map(&:name_en)

              @social_accounts = @social_accounts.where(city: cities)
            end

            if params[:profession] and params[:profession] != "全部"
              profession_params = params[:profession].split(",").reject(&:blank?)
              professions = Profession.where(name: profession_params).map(&:id)

              join_table(:social_account_professions)
              @social_accounts = @social_accounts.where("`social_account_professions`.`profession_id` IN (?)", professions)
            end

            if params[:sns] and params[:sns] != "全部"
              sns_params = params[:sns].split(",").reject(&:blank?)
              sns = sns_params & ["public_wechat", "weibo", "meipai", "miaopai"]

              @social_accounts = @social_accounts.where("`social_accounts`.`provider` IN (?)", sns)
            end

            if params[:price_range] and params[:price_range] != "全部"
              min_price, max_price = params[:price_range].split(",").map(&:to_i)
              if min_price >= 0 and max_price > min_price

                @social_accounts = @social_accounts.where("`social_accounts`.`price` BETWEEN ? AND ?", min_price, max_price)
              end
            end

            @social_accounts = @social_accounts.page(params[:page]).per_page(6)

            present @social_accounts, with: Entities::SocialAccount
            header "X-Page", @social_accounts.current_page
            header "X-Total-Pages", @social_accounts.total_pages
          end
        end
      end
    end
  end
end