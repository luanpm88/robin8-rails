module API
  module V1_7
    module Entities
      module CpsArticles
        class Summary < Grape::Entity
          expose :id, :title, :cover, :content, :show_url, :status, :check_remark, :material_total_price,
                 :writing_forecast_commission, :writing_settled_commission, :end_date
          expose :author, using: API::V1::Entities::KolEntities::InviteeSummary
          expose :cps_article_share_count do |cps_article|
            cps_article.cps_article_shares.count
          end
        end

        class WithShareDetail < Summary
          expose :cps_article_shares, using: API::V1_7::Entities::CpsArticleShares::Summary
        end

        class WithShareCommission < WithShareDetail
          expose :share_settled_commission, :share_forecast_commission
        end
      end
    end
  end
end
