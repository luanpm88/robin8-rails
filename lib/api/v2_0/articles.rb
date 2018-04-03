# encoding: utf-8
module API
  module V2_0
    class Articles < Grape::API
    	resources :articles do
        before do
          authenticate!
        end

        get '/' do
        	res = ElasticArticleExtend.get_by_tags(current_kol, $redis.get("kol_elastic_articles_#{current_kol.id}"))

        	$redis.set("kol_elastic_articles_#{current_kol.id}", res.last['post_date'])

        	present :error, 0
        	present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles
        end

        params do
          requires :_action, type: String, values: ElasticArticleAction::ACTIONS
          requires :post_id, type: String
        end
        post 'add' do
          eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: params[:_action], post_id: params[:post_id])

          eaa.save if eaa.new_record?

          present :error, 0, alert: '操作成功'
        end

        params do
          requires :_action, type: String, values: ElasticArticleAction::ACTIONS
          requires :post_id, type: String
        end
        post 'cancel' do
          eaa = current_kol.elastic_article_actions.find_by(_action: params[:_action], post_id: params[:post_id])

          eaa.destory if eaa

          present :error, 0, alert: '操作成功'
        end


      end
    end
  end
end