module API
  module V2
    class ArticleActions < Grape::API
      resources :article_actions do
        before do
          authenticate!
        end

        #我的文章操作
        params do
          requires :id, type: Integer
          requires :action, type: String, values: ['forward', 'collect', 'like']
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

        #搜藏列表
        get 'collect' do
          collect_article_actions = current_kol.article_actions.collect
          present :error, 0
          present :article_actions, collect_article_actions, with: API::V2::Entities::ArticleActionEntities::Summary
        end
      end
    end
  end
end
