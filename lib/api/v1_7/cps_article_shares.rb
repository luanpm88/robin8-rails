module API
  module V1_7
    class CpsArticleShares < Grape::API
      resources :cps_article_shares do
        before do
          authenticate!
        end

        #文章列表
        params do
          optional :page, type: Integer
        end
        get 'my_share' do
          cps_article_shares = current_kol.cps_article_shares.order("updated_at desc").page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(to_paginate(cps_article_shares))
          present :cps_article_shares, cps_article_shares, with: API::V1_7::Entities::CpsArticleShare::Summary
        end
      end
    end
  end
end
