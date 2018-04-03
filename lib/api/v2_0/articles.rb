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

      end
    end
  end
end