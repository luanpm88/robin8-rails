module Property
  module V1
    class Profile < Base
      include Property::V1::Helpers

      resource :profile do
        before do
          doorkeeper_authorize!
        end

        get "/" do
          present current_kol, with: Property::V1::Entities::Profile
        end

        params do
          optional :name, type: String
          optional :email, type: String
          optional :phone, type: String
          optional :avatar_url, type: String
        end
        put "/" do
          kol_params = ActionController::Parameters.new(params).permit(:name, :email)
          kol_params.merge!(remote_avatar_url: params[:avatar_url]) if params[:avatar_url]

          if current_kol.update(kol_params)
            present current_kol, with: Property::V1::Entities::Profile
          else
            error!({error: '修改用户信息出错了'}, 400)
          end
        end
      end
    end
  end
end