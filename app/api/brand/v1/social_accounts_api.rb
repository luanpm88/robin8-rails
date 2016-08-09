module Brand
  module V1
    class SocialAccountsAPI < Base
      helpers do
        def join_table(name)
          @join_state ||= {
            social_account_tags: false
          }

          unless @join_state[name]
            @social_accounts = @social_accounts.joins("INNER JOIN `#{name}` ON `social_accounts`.`id` = `#{name}`.`social_account_id`")
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
            optional :tag, type: String
            optional :sns, type: String
            optional :price_range, type: String
          end
          get "search" do
            @social_accounts = SocialAccount.all

            if params[:word].present?
              words = params[:word].gsub(/,|，/i, " ").split(" ")
              @social_accounts = @social_accounts.where('username REGEXP ?', words.join("|"))
            end

            if params[:region] and params[:region] != "全部"
              regions = params[:region].split(",").reject(&:blank?)
              cities = City.where(name: regions).map(&:name_en)

              @social_accounts = @social_accounts.where(city: cities)
            end

            if params[:tag] and params[:tag] != "全部"
              tag_params = params[:tag].split(",").reject(&:blank?)
              tags = Tag.where(name: tag_params).map(&:id)

              join_table(:social_account_tags)
              @social_accounts = @social_accounts.where("`social_account_tags`.`tag_id` IN (?)", tags)
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

          desc 'Get social account full data by id'
          params do
            requires :id, type: Integer
          end
          get ":id" do
            @social_account = SocialAccount.find(params[:id])
            present @social_account, with: Entities::SocialAccountDetail
          end
        end
      end
    end
  end
end