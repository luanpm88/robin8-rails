module API
  module V2
    class Articles < Grape::API
      resources :articles do
        before do
          authenticate!
        end

        #发现文章列表
        params do
          optional :type, type: String, values: ['discovery' ,'select']
          optional :title, type: String
        end
        get '/' do
          if params[:type] == 'select'
            articles = ::Articles::Store.get_select_like_list(current_kol.id)
          else
            last_request_time = Rails.cache.read("article_last_request_#{current_kol.id}") || nil
            return error_403!({error: 1, detail: '刷新过快，请稍后再试！' })   if  (Time.now -  last_request_time <= 2)  rescue false
            Rails.cache.write("article_last_request_#{current_kol.id}",Time.now)
            if params[:title]
              origin_page = Rails.cache.read("kol_search_#{params[:title]}_page") || 0
              page = origin_page + 1
              Rails.cache.write("kol_search_#{params[:title]}_page", page, :expires_in => 2.minutes)
            else
              page = 1
            end
            articles = ::Articles::Store.get_discovery_list(current_kol.id, params[:title], page )
          end
          return error_403!({error: 1, detail: '没有找到新文章！' })  if articles.size == 0
          present :error, 0
          present :articles_count, articles.size
          present :articles, articles, with: API::V2::Entities::ArticleEntities::Summary
        end

        #搜索文章列表
        params do
          requires :title, type: String
          optional :page, type: Integer
        end
        get 'search' do
          last_request_time = Rails.cache.read("article_last_request_#{current_kol.id}") || nil
          return error_403!({error: 1, detail: '刷新过快，请稍后再试！' })   if  (Time.now -  last_request_time <= 2)  rescue false
          Rails.cache.write("article_last_request_#{current_kol.id}",Time.now)

          articles = ::Articles::Store.get_discovery_list(current_kol.id, params[:title], params[:page] || 1)
          present :error, 0
          present :articles_count, articles.size
          present :articles, articles, with: API::V2::Entities::ArticleEntities::Summary
        end


        #用户 阅读/选择喜爱文章操作
        params do
          requires :article_id, type: String
          requires :article_title, type: String
          requires :article_url, type: String
          requires :article_avatar_url, type: String
          requires :article_author, type: String
          requires :action, type: String, values: ['look' ,'collect']
        end
        put 'action' do
          article_action = ArticleAction.action_from_list(params[:action], current_kol.id, params)
          present :error, 0
          present :article_action, article_action, with: API::V2::Entities::ArticleActionEntities::Summary
        end

      end
    end
  end
end
