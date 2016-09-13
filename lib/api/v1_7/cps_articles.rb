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
          cps_articles = CpsArticle.passed.includes(:kol).order("updated_at desc").page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(cps_articles)
          present :cps_articles, cps_articles, with: API::V1_7::Entities::CpsArticles::Summary
        end

        #我的创作列表
        params do
          optional :page, type: Integer
          requires :status, type: String
        end
        get 'my_articles' do
          if params[:status] == 'shares'
            cps_article_shares = current_kol.cps_article_shares.includes(:kol).order("updated_at desc").page(params[:page]).per_page(10)
            to_paginate(cps_article_shares)
            cps_articles = cps_article_shares.collect{|share| share.cps_article}
          else
            cps_articles = current_kol.cps_articles.send("#{params[:status]}").includes(:kol).order("created_at desc").page(params[:page]).per_page(10)
            cps_article_shares = [CpsArticleShare.new]
            to_paginate(cps_articles)
          end
          present :error, 0
          present :cps_articles, cps_articles, with: API::V1_7::Entities::CpsArticles::Summary
          present :cps_article_shares, cps_article_shares, with: API::V1_7::Entities::CpsArticleShares::Summary
        end

        #文章创作
        params do
          optional :id, type: Integer
          requires :title, type: String
          requires :content, type: String
          requires :cover, type: String
        end
        post 'create' do
          if params[:id].present?
            cps_article = current_kol.cps_articles.where(:id => params[:id]).first rescue nil
            return error_403!({error: 1, detail: '该文章不存在！' })  if cps_article.blank?
            return error_403!({error: 1, detail: '该文章已通过,不能被修改！' })  if cps_article.status == 'passed'
          else
            cps_article = current_kol.cps_articles.build
          end
          cps_article.title = params[:title]
          cps_article.content = params[:content]
          cps_article.cover = params[:cover]
          cps_article.status = 'pending'
          cps_article.save!
          present :error, 0
          present :cps_article, cps_article, with: API::V1_7::Entities::CpsArticles::Summary
        end

        # 文章详情
        get ':id/show' do
          cps_article = CpsArticle.where(:id => params[:id]).first rescue nil
          return error_403!({error: 1, detail: '该文章不存在！' })  if cps_article.blank?
          present :error, 0
          present :cps_article, cps_article, with: API::V1_7::Entities::CpsArticles::WithShareDetail
        end

        # 文章中所含商品
        get ':id/materials' do
          cps_article = CpsArticle.where(:id => params[:id]).first rescue nil
          return error_403!({error: 1, detail: '该文章不存在！' })  if cps_article.blank?
          present :error, 0
          present :cps_materials, cps_article.cps_materials, with: API::V1_7::Entities::CpsMaterials::Summary
        end

        # 分享文章
        params do
          optional :cps_article_id, type: Integer
        end
        post 'share_article' do
          cps_article = CpsArticle.find params[:cps_article_id]   rescue nil
          return error_403!({error: 1, detail: '该文章不存在！' })  if cps_article.blank? || cps_article.status != 'passed'
          cps_article_share = CpsArticleShare.find_or_create_by!(:kol_id => current_kol.id, :cps_article_id => params[:cps_article_id])
          present :error, 0
          present :cps_article_share, cps_article_share, with: API::V1_7::Entities::CpsArticleShares::Summary
        end
      end
    end
  end
end
