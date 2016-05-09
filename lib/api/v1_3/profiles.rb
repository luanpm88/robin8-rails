module API
  module V1_3
    class Profiles < Grape::API
      resources :profiles do
        before do
          authenticate!
        end

        get 'show' do
          kol_value = KolInfluenceValue.get_score(current_kol.kol_uuid)
          item_rate = kol_value.get_item_scores
          tasks = RewardTask.all
          present :item_rate, item_rate, with: API::V2::Entities::KolInfluenceValueEntities::History
          present :kol_value, kol_value, with: API::V2::Entities::KolInfluenceValueEntities::Summary
          present :tasks, tasks, with: API::V2::Entities::RewardTaskEntities::Summary, kol: current_kol
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
