# coding: utf-8
module API
  module V2_0
    class Announcements < Grape::API
      resources :announcements do
        before do
          authenticate!
        end

        params do
          requires :announcement_id, type: Integer
          optional :params_json,  type: String
        end
        post 'click' do
        	as = AnnouncementShow.create(
        		kol_id: current_kol.id, 
        		announcement_id: params[:announcement_id],
        		params_json: params[:params_json].to_json
        	)

        	present error: 0, alert: '操作成功'

        end

      end
    end
  end
end