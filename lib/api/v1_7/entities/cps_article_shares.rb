module API
  module V1_7
    module Entities
      module CpsArticleShares
        class Summary < Grape::Entity
          expose :id, :show_url, :created_at
          # expose :cps_article, using: API::V1_7::Entities::CpsArticle::Summary
        end
      end
    end
  end
end
