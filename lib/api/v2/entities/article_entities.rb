module API
  module V2
    module Entities
      module ArticleEntities
        class Summary  < Grape::Entity
          expose :article_id do |article|
            article['id']
          end
          expose :article_title do |article|
            article['title_orig']
          end
          expose :article_url do |article|
            article['url']
          end
          expose :article_avatar_url do |article|
            article['msg_cdn_url'] + "300"
          end
          expose :article_author do |article|
            article['biz_name']
          end
          expose :article_author do |article|
            article['biz_name']
          end
        end
      end
    end
  end
end
