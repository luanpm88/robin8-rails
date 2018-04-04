# encoding: utf-8
module API
  module V2_0
    class Articles < Grape::API
    	resources :articles do
        before do
          authenticate!
        end

        params do
          requires :page, type: Integer
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

          my_elastic_articles = current_kol.elastic_article_actions

        	present :error,  0
          present :labels, [[:common, '新鲜事'], [:hot, '今日热点']]
          present :total_count, 999
          present :total_pages, 999
          present :current_page, params[:page]
        	present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles, my_elastic_articles: my_elastic_articles
        end

        params do
          requires :_type, type: String, values: ElasticArticleAction::ACTIONS
          requires :post_id, type: String
          requires :'_action', type: String, values: ['add', 'cancel']
        end
        post 'set' do
          eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: params[:_action], post_id: params[:post_id])

          if params[:_action] == 'add'
            eaa.save if eaa.new_record?
          else
            eaa.destory if eaa
          end

          present :error, 0, alert: '操作成功'
        end

      end
    end
  end
end