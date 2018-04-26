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
            $redis.set("elastic_articles_#{current_kol.id}", elastic_article_newest_post_id)
            $redis.set("elastic_articles_hot_#{current_kol.id}", elastic_article_newest_post_id)
          end

          if params[:_type] == 'hot' || params[:type] == 'hot'
            res = ElasticArticleExtend.get_by_hots($redis.get("elastic_articles_hot_#{current_kol.id}"))

            $redis.set("elastic_articles_hot_#{current_kol.id}", res[-1]['post_id'])
          else
        	  res = ElasticArticleExtend.get_by_tags(current_kol, $redis.get("elastic_articles_#{current_kol.id}"))

            $redis.set("elastic_articles_#{current_kol.id}", res[-1]['post_id'])
          end

        	present :error,  0
          present :labels, [[:common, '新鲜事'], [:hot, '今日热点']]
          present :total_count, 999
          present :total_pages, 999
          present :current_page, params[:page]
        	present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles, my_elastic_articles: my_elastic_articles(res.collect{|ele| ele['post_id']})
        end

        params do
          requires :tag,      type: String
          requires :post_id,  type: String
        end
        get 'recommends' do
          res = ElasticArticleExtend.recommend_by_tag(params[:tag], params[:post_id])

          present :error, 0
          present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles, my_elastic_articles: my_elastic_articles(res.collect{|ele| ele['post_id']})
        end

        params do
          requires :_type,   type: String, values: ['like', 'collect', 'forward']
          requires :post_id, type: String
          requires :_action, type: String, values: ['add', 'cancel']
          optional :tag,     type: String
        end
        post 'set' do
          eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: params[:_type], post_id: params[:post_id])

          if params[:_action] == 'add'
            if eaa.new_record?
              eaa.save 
              $redis.hincrby("elastic_article_#{eaa.post_id}", params[:_type], amount=1)

              
              ElasticArticle.create(post_id: params[:post_id], tag: Tag.find_by_name(params[:tag])) unless eaa.elastic_article
            end
          else
            if eaa
              eaa.destroy
              $redis.hincrby("elastic_article_#{eaa.post_id}", params[:_type], amount=-1)
            end
          end

          present :error, 0, alert: '操作成功'
        end

        params do
          requires :post_id,   type: String
          requires :stay_time, type: Integer
          optional :tag,       type: String
        end
        post 'read' do
          return error_403!({error: 1, detail: '停留时长太短，不予保留'}) if params[:stay_time].to_i <= 1

          eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: 'read', post_id: params[:post_id])
          eaa.stay_time = params[:stay_time]

          eaa.save
          
          ElasticArticle.create(post_id: params[:post_id], tag: Tag.find_by_name(params[:tag])) unless eaa.elastic_article

          present :error, 0, alert: '操作成功'
        end

      end
    end
  end
end