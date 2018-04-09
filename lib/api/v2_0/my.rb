# encoding: utf-8
module API
  module V2_0
    class My < Grape::API
    	resources :my do
        before do
          authenticate!
        end

        params do
          requires :_action, type: String, values: %w(likes collects)
          requires :page, type: Integer
        end
        get 'article_lists' do
          my_elastic_articles = current_kol.elastic_article_actions.send(params[:_action])
          post_ids    = my_elastic_articles.map(&:post_id)
          select_ids  = post_ids[(params[:page].to_i-1)*10..params[:page].to_i*10-1]

          res = ElasticArticleExtend.get_by_post_ids(select_ids)

 
          present :error, 0
          present :total_count, post_ids.count
          present :total_pages, page_count(post_ids.count).to_i
          present :current_page, params[:page]
          present :list, res, with: API::V2_0::Entities::InfluenceEntities::Articles, my_elastic_articles: my_elastic_articles
        end

      end
    end
  end
end