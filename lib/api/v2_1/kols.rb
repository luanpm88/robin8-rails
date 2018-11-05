# coding: utf-8
module API
  module V2_1
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        desc 'update kol base info'
        params do
          optional :name,                 type: String
          optional :gender,               type: Integer, values: [1, 2]
          optional :kol_role,             type: String, values: %w(public big_v creator)
          optional :age,                  type: String
          optional :job_info,             type: String
          optional :circle_ids,           type: String, default: ''
          optional :wechat_friends_count, type: Integer
        end
        post 'base_info' do
          current_kol.name                  = params[:name]                 if params[:name]
          current_kol.gender                = params[:gender]               if params[:gender]
          current_kol.age                   = params[:age]                  if params[:age]
          current_kol.job_info              = params[:job_info]             if params[:job_info]
          current_kol.wechat_friends_count  = params[:wechat_friends_count] if params[:wechat_friends_count]
          current_kol.avatar                = params[:avatar]               if params[:avatar]

          if params[:kol_role]
            current_kol.kol_role          = params[:kol_role]             
            current_kol.role_apply_status = params[:kol_role] == 'public' ? 'pending' : 'applying'
          end
 
          current_kol.save

          circle_ids = params[:circle_ids].split(',').collect{|ele| ele.to_i}

          if (current_kol.circle_ids & circle_ids) != circle_ids
            select_circles = Circle.where(id: circle_ids)
            if select_circles.present?
              current_kol.circles.delete_all
              current_kol.circles << select_circles
            end
          end

          present :error, 0
          present :kol,   current_kol.reload, with: API::V2_1::Entities::KolEntities::BaseInfo
        end

        desc 'applying creator'
        params do
          requires :circle_ids,   type: String
          requires :terrace_ids,  type: String
          requires :price,        type: Float
          requires :video_price,  type: Float
          requires :fans_count,   type: Integer
          requires :gender,       type: Integer, values: [1, 2]
          requires :age_range,    type: Integer
          requires :cities,       type: String
          requires :content_show, type: String
          optional :remark,       type: String
        end
        post 'applying_creator' do
          creator = current_kol.creator ? current_kol.creator : Creator.new(kol_id: current_kol.id)

          creator.price         = params[:price]
          creator.video_price   = params[:video_price]
          creator.fans_count    = params[:fans_count]
          creator.gender        = params[:gender]
          creator.age_range     = params[:age_range]
          creator.content_show  = params[:content_show]
          creator.remark        = params[:remark]
          creator.status        = 0

          error_403!(detail: '请重新输入正确的信息。') unless creator.save

          circle_ids = params[:circle_ids].split(',').collect{|ele| ele.to_i}
          if (creator.circle_ids & circle_ids) != circle_ids
            select_circles = Circle.where(id: circle_ids)
            if select_circles.present?
              creator.circles.delete_all
              creator.circles << select_circles
            end
          end

          terrace_ids = params[:terrace_ids].split(',').collect{|ele| ele.to_i}
          if (creator.terrace_ids.collect{|ele| ele.to_s} & terrace_ids) != terrace_ids
            select_terraces = Terrace.where(id: terrace_ids)
            if select_terraces.present?
              creator.terraces.delete_all
              creator.terraces << select_terraces
            end
          end

          cities = params[:cities].split(',')
          if (creator.cities.map(&:name) & cities) != cities
            select_cities = City.where(name: cities)
            if select_cities.present?
              creator.cities.delete_all
              creator.cities << select_cities
            end
          end

          present :error, 0
          present :kol,   current_kol.reload, with: API::V2_1::Entities::KolEntities::BaseInfo
        end


        desc 'applying weibo account'
        params do
          requires :nickname,         type: String
          requires :circle_ids,       type: String
          requires :auth_type,        type: Integer, values: [1,2,3]
          requires :fwd_price,        type: Float
          requires :price,            type: Float
          requires :live_price,       type: Float
          requires :quote_expired_at, type: DateTime
          requires :fans_count,       type: Integer
          requires :gender,           type: Integer, values: [1, 2]
          requires :cities,           type: String
          requires :content_show,     type: String
          optional :remark,           type: String
        end
        post 'applying_weibo_account' do
          weibo_account = current_kol.weibo_account ? current_kol.weibo_account : WeiboAccount.new(kol_id: current_kol.id)

          weibo_account.nickname          = params[:nickname]
          weibo_account.auth_type         = params[:auth_type]
          weibo_account.fwd_price         = params[:fwd_price]
          weibo_account.price             = params[:price]
          weibo_account.live_price        = params[:live_price]
          weibo_account.quote_expired_at  = params[:quote_expired_at]
          weibo_account.fans_count        = params[:fans_count]
          weibo_account.gender            = params[:gender]
          weibo_account.content_show      = params[:content_show]
          weibo_account.remark            = params[:remark]
          weibo_account.status            = 0

          error_403!(detail: '请重新输入正确的信息。') unless weibo_account.save

          circle_ids = params[:circle_ids].split(',').collect{|ele| ele.to_i}
          if (weibo_account.circle_ids & circle_ids) != circle_ids
            select_circles = Circle.where(id: circle_ids)
            if select_circles.present?
              weibo_account.circles.delete_all
              weibo_account.circles << select_circles
            end
          end

          cities = params[:cities].split(',')
          if (weibo_account.cities.map(&:name) & cities) != cities
            select_cities = City.where(name: cities)
            if select_cities.present?
              weibo_account.cities.delete_all
              weibo_account.cities << select_cities
            end
          end

          present :error, 0
          present :kol,   current_kol.reload, with: API::V2_1::Entities::KolEntities::BaseInfo
        end


        desc 'applying public wechat account'
        params do
          requires :nickname,         type: String
          requires :circle_ids,       type: String
          requires :price,            type: Float
          requires :mult_price,       type: Float
          requires :sub_price,        type: Float
          requires :n_price,          type: Float
          requires :quote_expired_at, type: DateTime
          requires :fans_count,       type: Integer
          requires :gender,           type: Integer, values: [1, 2]
          requires :cities,           type: String
          requires :content_show,     type: String
          optional :remark,           type: String
        end
        post 'applying_public_wechat_account' do
          public_wechat_account = current_kol.public_wechat_account ? current_kol.public_wechat_account : PublicWechatAccount.new(kol_id: current_kol.id)

          public_wechat_account.nickname          = params[:nickname]
          public_wechat_account.price             = params[:price]
          public_wechat_account.mult_price        = params[:mult_price]
          public_wechat_account.sub_price         = params[:sub_price]
          public_wechat_account.n_price           = params[:n_price]
          public_wechat_account.quote_expired_at  = params[:quote_expired_at]
          public_wechat_account.fans_count        = params[:fans_count]
          public_wechat_account.gender            = params[:gender]
          public_wechat_account.content_show      = params[:content_show]
          public_wechat_account.remark            = params[:remark]
          public_wechat_account.status            = 0

          error_403!(detail: '请重新输入正确的信息。') unless public_wechat_account.save

          circle_ids = params[:circle_ids].split(',').collect{|ele| ele.to_i}
          if (public_wechat_account.circle_ids & circle_ids) != circle_ids
            select_circles = Circle.where(id: circle_ids)
            if select_circles.present?
              public_wechat_account.circles.delete_all
              public_wechat_account.circles << select_circles
            end
          end

          cities = params[:cities].split(',')
          if (public_wechat_account.cities.map(&:name) & cities) != cities
            select_cities = City.where(name: cities)
            if select_cities.present?
              public_wechat_account.cities.delete_all
              public_wechat_account.cities << select_cities
            end
          end

          present :error, 0
          present :kol,   current_kol.reload, with: API::V2_1::Entities::KolEntities::BaseInfo
        end

        desc 'get kol base info'
        get 'my_show' do
          present :error, 0
          present :kol, current_kol, with: API::V2_1::Entities::KolEntities::BaseInfo
        end
      end
    end
  end
end