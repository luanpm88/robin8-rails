module API
  module V2
    class Articles < Grape::API
      resources :articles do
        before do
          authenticate!
        end

        #文章列表
        get '/' do
          articles = ::Articles::Store.get_list(current_kol.id)
          present :error, 0
          present :articles, articles, with: API::V2::Entities::ArticleEntities::Summary
        end

        #用户 文章操作
        params do
          requires :action, type: String, values: ['read', 'forward', 'collect', 'like']
          requires :article_id, type: String
          requires :article_title, type: String
          requires :article_url, type: String
          requires :article_avatar_url, type: String
          requires :article_author, type: String
        end
        put 'article_action' do
          ArticleAction.article_action(current_kol.id, params[:action], params)
          present :error, 0
          present :detail, 0
        end
      end
    end
  end
end
