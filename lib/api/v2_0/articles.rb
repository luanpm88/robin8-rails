# encoding: utf-8
module API
  module V2_0
    class Articles < Grape::API
    	resources :articles do
        before do
          authenticate!
        end

        params do
          optional :_type, type: String
        end
        get '/' do
          if params[:_type] == 'hot'
            res = ElasticArticleExtend.get_by_hots($redis.get("kol_elastic_articles_hot_#{current_kol.id}"))

            $redis.setex("kol_elastic_articles_hot_#{current_kol.id}", 43200, res[-1]['post_id'])
          else
        	  res = ElasticArticleExtend.get_by_tags(current_kol, $redis.get("kol_elastic_articles_#{current_kol.id}") || Time.now.to_i)
            
            $redis.setex("kol_elastic_articles_#{current_kol.id}", 43200, res[-1]['post_date'])
            $redis.setex("kol_elastic_articles_hot_#{current_kol.id}", 43200, res[0]['post_id']) unless $redis.get("kol_elastic_articles_hot_#{current_kol.id}")
          end

        	present :error,  0
          present :labels, [[:common, '新鲜事'], [:hot, '今日热点']]
        	present :list,   res, with: API::V2_0::Entities::InfluenceEntities::Articles, current_kol: current_kol
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