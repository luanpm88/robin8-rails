module API
  module V2
    module Entities
      module ArticleActionEntities
        class Summary  < Grape::Entity
          expose :id, :article_id, :article_url, :article_avatar_url, :article_title, :article_author,
                 :look, :forward, :collect, :like, :share_url
          expose :read_count do |article_action|
            article_action.redis_click.value
          end
        end
      end
    end
  end
end
