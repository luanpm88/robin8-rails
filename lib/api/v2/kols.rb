module API
  module V2
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        params do
          requires :app_platform, type: String
          requires :app_version, type: String
          requires :device_token, type: String
          requires :os_version, type: String
          requires :device_model, type: String
          optional :city_name, type: String
          optional :IDFA, type: String
          optional :IMEI, type: String
        end
        put 'update_profile' do
          current_kol.reg_or_sign_in(params)
        end
      end
    end
  end
end
