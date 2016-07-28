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
          optional :profession_id, type: Integer
        end
        get '' do
          if params[:profession_id].blank?
            big_v = Kol.order_by_hot.per(10).page(params[:page])
          else
            big_v = Kol.joins(:kol_professions).where("kol_professions.profession_id = #{params[:profession_id]}").order_by_hot.per(10).page(params[:page])
          end
          present :error, 0
          present :big_v, big_v, with: API::V1::Entities::TagEntities::Summary
        end
      end
    end
  end
end
