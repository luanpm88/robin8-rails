# encoding: utf-8
module API
  module V2_0
    class Articles < Grape::API
    	resources :articles do
        before do
          authenticate!
        end

        ORIGIN_ARRAY = Array.new(20, 0) + (0.01..0.1).step(0.01).collect{|ele| ele.round(2)}

        params do
          requires :page, type: Integer
          optional :_type, type: String
        end
        get '/' do
          if params[:page].to_i < 2
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

          # ElasticArticleWorker.perform(res)

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
          post_id = $redis.get("elastic_articles_recommends_#{current_kol.id}")
          post_id = params[:post_id] unless post_id
          
          res = ElasticArticleExtend.recommend_by_tag(params[:tag], post_id)

          $redis.setex("elastic_articles_recommends_#{current_kol.id}", 7200, res.last['post_id'])

          present :error, 0
          present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles, my_elastic_articles: my_elastic_articles(res.collect{|ele| ele['post_id']})
        end

        params do
          requires :_type,   type: String, values: ['like', 'collect', 'forward']
          requires :post_id, type: String
          requires :_action, type: String, values: ['add', 'cancel']
          optional :tag,     type: String
          optional :title,   type: String
        end
        post 'set' do

          ea = ElasticArticle.find_or_initialize_by(post_id: params[:post_id])
          
          if ea.new_record?
            ea.title = params[:title][0,100]         if params[:title]
            ea.tag = Tag.find_by_name(params[:tag])  if params[:tag]
            ea.save
          end

          eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: params[:_type], post_id: params[:post_id])

          if params[:_action] == 'add'
            if eaa.new_record?
              eaa.save
              ea.send("redis_#{params[:_type]}s_count").increment
              current_kol.send("redis_elastic_#{params[:_type]}s_count").increment
            end
          else
            if eaa
              eaa.destroy
              ea.send("redis_#{params[:_type]}s_count").decrement
              current_kol.send("redis_elastic_#{params[:_type]}s_count").decrement
            end
          end

          present :error, 0, alert: '操作成功'
        end

        params do
          requires :post_id,   type: String
          requires :stay_time, type: Integer
          optional :tag,       type: String
          optional :title,     type: String
        end
        post 'read' do
          return error_403!({error: 1, detail: '停留时长太短，不予保留'}) if params[:stay_time].to_i <= 1

          # ea = ElasticArticle.find_or_initialize_by(post_id: params[:post_id])

          # if ea.new_record?
          #   ea.title = params[:title][0,100]         if params[:title]
          #   ea.tag = Tag.find_by_name(params[:tag])  if params[:tag]
          #   ea.save
          # end

          # eaa = current_kol.elastic_article_actions.find_or_initialize_by(_action: 'read', post_id: params[:post_id])
          # eaa.stay_time = params[:stay_time]

          # eaa.save

          # ea.redis_reads_count.increment
          # ea.redis_stay_time.incr(eaa.stay_time)

          $redis.incr 'elastic_article_show_count'
          $redis.incrby 'elastic_article_show_time', params[:stay_time].to_i

          current_kol.redis_elastic_reads_count.increment
          current_kol.redis_elastic_stay_time.incr(params[:stay_time].to_i)

          present :error, 0
          present :alert, '操作成功'
          present :red_money, current_kol.transactions.recent(Time.now, Time.now).subjects('red_money').count < 10 ? ORIGIN_ARRAY.sample : 0
        end

        params do
          requires :red_money, type: Float
        end
        post 'split_red' do 
          return error_403!({error: 1, detail: '超出每日红包限制'}) if current_kol.transactions.recent(Time.now, Time.now).subjects('red_money').count >= 10
          return error_403!({error: 1, detail: '红包金额有误'})  if params[:red_money].to_f > 0.1
          current_kol.income(params[:red_money].to_f, 'red_money')

          $redis.incrby 'elastic_article_red_money', (params[:red_money].to_f * 100).to_i

          present :error, 0
          present :alert, '操作成功' 
        end

      end
    end
  end
end