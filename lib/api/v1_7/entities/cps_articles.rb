module API
  module V1_7
    module Entities
      module CpsArticles
        class Summary < Grape::Entity
          expose :id, :title, :cover, :content, :show_url, :status, :check_remark, :material_total_price
          expose :kol, using: API::V1::Entities::KolEntities::InviteeSummary
          expose :cps_article_shares, using: API::V1_7::Entities::CpsArticleShares::Summary
        end
      end
    end
  end
end
