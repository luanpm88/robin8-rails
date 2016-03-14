module API
  module V2
    class Articles < Grape::API
      resources :articles do
        before do
          authenticate!
        end

        #文章列表
        params do
          optional :title, type: String
        end
        get '/' do
          articles = ::Articles::Store.get_list(current_kol.id, params[:title])
          present :error, 0
          present :articles, articles, with: API::V2::Entities::ArticleEntities::Summary
        end

        #用户 文章操作
        params do
          requires :article_id, type: String
          requires :article_title, type: String
          requires :article_url, type: String
          requires :article_avatar_url, type: String
          requires :article_author, type: String
        end
        put 'read_article' do
          ArticleAction.article_action(current_kol.id, params)
          present :error, 0
          present :articles, articles, with: API::V2::Entities::ArticleActionEntities::Summary
        end

        #用户 文章操作
        params do
          requires :id, type: Integer
          requires :action, type: String, values: ['read', 'forward', 'collect', 'like']
        end
        put ':id/action' do
          article_action = current_kol.article_actions.where(:id => params[:id]).first rescue nil
          if article_action
            article_action = article_action.action(params[:action])
            present :error, 0
            present :article_action, article_action, with: API::V2::Entities::ArticleActionEntities::Summary
          else
            return error_403!({error: 1, detail: '该文章不错存在'})
          end
        end
      end
    end
  end
end
