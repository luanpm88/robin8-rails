module API
  module V2
    class Articles < Grape::API
      resources :articles do
        before do
          authenticate!
        end

        #发现文章列表
        params do
          optional :type, type: String, values: ['discovery' ,'select']
          optional :title, type: String
        end
        get '/' do
          if params[:type] == 'select'
            title = current_kol.tags.collect{|t| t.label }.join(' ')
            articles = ::Articles::Store.get_select_like_list(current_kol.id, title)
          else
            articles = ::Articles::Store.get_discovery_list(current_kol.id, params[:title])
          end
          present :error, 0
          present :articles, articles, with: API::V2::Entities::ArticleEntities::Summary
        end

        #用户 阅读/选择喜爱文章操作
        params do
          requires :article_id, type: String
          requires :article_title, type: String
          requires :article_url, type: String
          requires :article_avatar_url, type: String
          requires :article_author, type: String
          requires :action, type: String, values: ['look' ,'collect']
        end
        put 'action' do
          article_action = ArticleAction.action_from_list(params[:action], current_kol.id, params)
          present :error, 0
          present :article_action, article_action, with: API::V2::Entities::ArticleActionEntities::Summary
        end

      end
    end
  end
end
