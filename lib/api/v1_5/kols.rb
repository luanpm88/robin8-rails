module API
  module V1_5
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        # 用户
        params do
          requires :id, type: Integer
        end
        get ':id/invitee_detail' do
          invitee  = Kol.find params[:id]
          present :invitee, invitee, with: API::V1::Entities::KolEntities::InviteeDetail
        end
      end
    end
  end
end
