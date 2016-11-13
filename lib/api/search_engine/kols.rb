module API
  module SearchEngine
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate_from_engine!
        end

        #搜索kol
        params do
          optional :tag_label, type: String
          optional :provider, type: String, values: ['weibo', 'public_wechat']
        end
        get 'list' do
          tag_id = Tag.where(:label => params[:tag_label]).first rescue nil
          if params[:tag_label].present? && tag_id.nil?
            present :error, 1
            present :detail, '没有找到该分类'
          else
            sql = "select social_accounts.search_kol_id from social_accounts
                   left join social_account_tags on social_accounts.id =  social_account_tags.social_account_id
                   where social_accounts.search_kol_id is not null"
            if params[:provider].present?
              sql << " and social_accounts.provider = '#{params[:provider]}'"
            end
            if tag_id.present?
              sql << " and social_account_tags.tag_id = '#{tag_id}'"
            end
            kol_ids = SocialAccount.find_by_sql(sql).collect{|t| t.search_kol_id}
            present :error, 0
            present :kol_ids, kol_ids
          end
        end

        #获取kol详情
        params do
          requires :kol_id, type: String
        end
        get ':kol_id/detail' do
          kol = Kol.find params[:kol_id]
          social_account = SocialAccount.where(:search_kol_id => params[:kol_id]).first rescue nil
          if social_account.blank?
            present :error, 1
            present :detail, '该用户未找到'
          else
            social_accounts = SocialAccount.where(:kol_id => social_account.kol_id)
            present :error, 0
            present :social_account, social_accounts, with: API::SearchEngine::Entities::KolEntities::SocialAccount
            present :show_count, kol.show_count
          end
        end


        # 修改kol 社交账号价格
        params do
          requires :social_account_id, type: Integer
          requires :price, type: Float
          optional :second_price, type: Float
          optional :repost_price, type: Float
        end
        post 'update_price' do
          social_account = SocialAccount.where(:id => params[:social_account_id]).first rescue nil
          if social_account.blank?
            present :error,1
            present :detail, '该社交账号未找到'
          else
            social_account.update_columns(:price =>  params[:price], :second_price => params[:second_price], :repost_price => params[:repost_price])
            present :error,0
          end
        end
      end
    end
  end
end
