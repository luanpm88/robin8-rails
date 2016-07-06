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
          optional :avatar, type: Rack::Multipart::UploadedFile
        end
        put "/" do
          if current_kol.update(
              name: params[:name],
              email: params[:email],
              avatar: params[:avatar])
            present current_kol, with: Property::V1::Entities::Profile
          else
            error!({error: '修改用户信息出错了'}, 400)
          end
        end
      end
    end
  end
end