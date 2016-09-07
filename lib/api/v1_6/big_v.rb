module API
  module V1_6
    class BigV < Grape::API
      resources :big_v do
        desc '列表'
        params do
          optional :page, type: Integer
          optional :with_kol_announcement, type: String
          optional :tag_name, type: String
          optional :name, type: String
          optional :order, type: String, values: ['order_by_hot', 'order_by_created']
        end
        get '/' do
          order_by = params[:order] || 'order_by_hot'
          per_page = order_by == 'order_by_hot' ? 20 : 40
          if params[:tag_name].blank?
            big_vs = Kol.where("kol_role = 'mcn_big_v' or kol_role = 'big_v'").where("kols.name like '%#{params[:name]}%'").includes(:kol_tags => [:tag]).send("#{order_by}").page(params[:page]).per_page(per_page)
          else
            tag_id = Tag.find_by(:name => params[:tag_name]).id
            big_vs = Kol.where("kol_role = 'mcn_big_v' or kol_role = 'big_v'").where("kols.name like '%#{params[:name]}%'").joins(:kol_tags => [:tag]).where("kol_tags.tag_id = #{tag_id}").
                       send("#{order_by}").page(params[:page]).per_page(per_page)
          end
          if params[:with_kol_announcement] == 'Y'
            kol_announcements = KolAnnouncement.enable.order_by_position
            present :kol_announcements, kol_announcements, with: API::V1_6::Entities::KolAnnouncementEntities::Summary
          end
          present :error, 0
          to_paginate(big_vs)
          present :big_vs, big_vs, with: API::V1_6::Entities::BigVEntities::Summary
        end

        desc '详情'
        get 'detail' do
          big_v =  current_kol
          present :error, 0
          present :big_v, big_v, with: API::V1_6::Entities::BigVEntities::Detail
          present :kol_shows, big_v.kol_shows, with: API::V1_6::Entities::KolShowEntities::Summary
          present :kol_keywords, big_v.kol_keywords, with: API::V1_6::Entities::KolKeywordEntities::Summary
          present :social_accounts, big_v.social_accounts, with: API::V1_6::Entities::SocialAccountEntities::Summary
          present :is_follow, (current_kol.is_follow?(big_v) rescue false) == true ? 1 : 0
        end

        desc '详情'
        get ':id/detail' do
          big_v = (Kol.find params[:id]  rescue nil)  || current_kol
          if big_v
            if big_v.kol_keywords.size == 0
              kol_keywords = []
              big_v.tags.each do |tag|
                kol_keywords << KolKeyword.new(:keyword => tag.label)
              end
            else
              kol_keywords = big_v.kol_keywords
            end
            present :error, 0
            present :big_v, big_v, with: API::V1_6::Entities::BigVEntities::Detail
            present :kol_shows, big_v.kol_shows, with: API::V1_6::Entities::KolShowEntities::Summary
            present :kol_keywords, kol_keywords, with: API::V1_6::Entities::KolKeywordEntities::Summary
            present :social_accounts, big_v.social_accounts, with: API::V1_6::Entities::SocialAccountEntities::Summary
            present :is_follow, (current_kol.is_follow?(big_v) rescue false) == true ? 1 : 0
          else
            present :error, 1
            present :detail, '该用户不存在'
          end
        end

        desc '关注kol'
        params do
          optional :id, type: Integer
        end
        post ':id/follow' do
          big_v = Kol.find params[:id]  rescue nil
          if current_kol.blank?
            present :error, 1
            present :detail, '请您先登录'
          elsif big_v
            current_kol.follow(big_v)
            present :error, 0
          else
            present :error, 1
            present :detail, '该用户不存在'
          end
        end
      end
    end
  end
end
