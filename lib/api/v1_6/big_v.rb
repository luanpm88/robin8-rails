module API
  module V1_6
    class BigV < Grape::API
      before do
        authenticate!
      end

      resources :big_v do
        desc '列表'
        params do
          optional :page, type: Integer
          optional :with_kol_announcement, type: String
          optional :profession_name, type: Integer
        end
        get '/' do
          if params[:profession_name].blank?
            big_vs = Kol.big_v.includes(:kol_professions => [:profession]).order_by_hot.page(params[:page]).per_page(10)
          else
            profession_id = Profession.find_by(:name => params[:profession_name]).id
            big_vs = Kol.big_v.joins(:kol_professions).where("kol_professions.profession_id = #{profession_id}").
                    order_by_hot.page(params[:page]).per_page(10)
          end
          if params[:with_kol_announcement] == 'Y'
            kol_announcements = KolAnnouncement.enable
            present :kol_announcements, kol_announcements, with: API::V1_6::Entities::KolAnnouncementEntities::Summary
          end
          present :error, 0
          present :big_vs, big_vs, with: API::V1_6::Entities::BigVEntities::Summary
        end

        desc '详情'
        params do
          optional :id, type: Integer
        end
        get ':id/detail' do
          big_v = Kol.find params[:id]
          if big_v.is_big_v?
            present :error, 0
            present :big_v, big_v, with: API::V1_6::Entities::BigVEntities::Detail
            present :kol_shows, big_v.kol_shows, with: API::V1_6::Entities::KolShowEntities::Summary
            present :kol_keywords, big_v.kol_keywords, with: API::V1_6::Entities::KolKeywordEntities::Summary
            present :social_accounts, big_v.social_accounts, with: API::V1_6::Entities::SocialAccountEntities::Summary
          else
            present :error, 1
            present :detail, '该用户不存在,或者不是网红'
          end
        end
      end
    end
  end
end
