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
          optional :kol_announcement, type: String
          optional :profession_id, type: Integer
        end
        get '' do
          if params[:profession_id].blank?
            big_vs = Kol.includes(:professsions, :kol_shows, :kol_keywords).order_by_hot.per(10).page(params[:page])
          else
            big_vs = Kol.joins(:kol_professions).includes(:professsions, :kol_shows, :kol_keywords).where("kol_professions.profession_id = #{params[:profession_id]}").order_by_hot.per(10).page(params[:page])
          end
          if params[:kol_announcement] == 'Y'
            kol_announcements = KolAnnouncement.enable
            present :kol_announcements, kol_announcements, with: API::V6::Entities::KolAnnouncementEntities::Summary
          end
          present :error, 0
          present :big_vs, big_vs, with: API::V1_6::BigVEntities::Summary
        end
      end
    end
  end
end
