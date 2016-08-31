module API
  module V1_7
    class CpsArticles < Grape::API
      resources :cps_articles do
        before do
          authenticate!
        end

        #文章列表
        params do
          optional :page, type: Integer
        end
        get '/' do
          cps_articles = current_kol.cps_articles.order("updated_at desc").page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(to_paginate(@campaign_invites))
          present :cps_articles, cps_articles, with: API::V1_7::Entities::CpsArticle::Summary
        end

        #文章创作
        params do
          optional :id, type: Integer
          requires :title, type: String
          requires :content, type: String
          optional :cover, type: Hash
        end
        post 'create' do
          if params[:id].present?
            cps_article = current_kol.cps_articles.where(:id => params[:id]).first rescue nil
            return error_403!({error: 1, detail: '该文章不存在！' })  if cps_article.blank?
          else
            cps_article = current_kol.cps_articles.build
          end
          cps_article.title = params[:title]
          cps_article.content = params[:content]
          cps_article.cover = params[:cover] if params[:cover].present?
          cps_article.save
          present :error, 0
          present :cps_article, cps_article, with: API::V1_7::Entities::CpsArticle::Summary
        end

        get ':id/show' do
          cps_article = current_kol.cps_articles.where(:id => params[:id]).first rescue nil
          return error_403!({error: 1, detail: '该文章不存在！' })  if cps_article.blank?
          present :error, 0
          present :cps_article, cps_article, with: API::V1_7::Entities::CpsArticle::Summary
        end
      end
    end
  end
end
