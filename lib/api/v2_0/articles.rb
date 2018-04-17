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
          if params[:page] == '1'
            $redis.setex("elastic_articles_#{current_kol.id}", 43200, ElasticArticleExtend.get_new_post_id)
          end
          if params[:_type] == 'hot' || params[:type] == 'hot'
            res = ElasticArticleExtend.get_by_hots($redis.get("elastic_articles_#{current_kol.id}"))
          else
        	  res = ElasticArticleExtend.get_by_tags(current_kol, $redis.get("elastic_articles_#{current_kol.id}"))
          end
          $redis.setex("elastic_articles_#{current_kol.id}", 43200, res[-1]['post_id'])

          my_elastic_articles = {}
          current_list = current_kol.elastic_article_actions.where(post_id: res.collect{|ele| ele['post_id']})
          my_elastic_articles[:likes] = current_list.likes.map(&:post_id)
          my_elastic_articles[:collects] = current_list.collects.map(&:post_id)
        	present :error,  0
          present :labels, [[:common, '新鲜事'], [:hot, '今日热点']]
          present :total_count, 999
          present :total_pages, 999
          present :current_page, params[:page]
        	present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles, my_elastic_articles: my_elastic_articles
        end

        params do
          requires :_type, type: String, values: ['like', 'collect', 'forward']
          requires :post_id, type: String
          requires :_action, type: String, values: ['add', 'cancel']
        end
        post 'set' do
          eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: params[:_type], post_id: params[:post_id])

          if params[:_action] == 'add'
            if eaa.new_record?
              eaa.save 
              $redis.hincrby("elastic_article_#{eaa.post_id}", params[:_type], amount=1)
            end
          else
            if eaa
              eaa.destroy
              $redis.hincrby("elastic_article_#{eaa.post_id}", params[:_type], amount=-1)
            end
          end

          present :error, 0, alert: '操作成功'
        end

      end
    end
  end
end