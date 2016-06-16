module API
  module V1_4
    class CpiReg < Grape::API
      ApiToken = "ecce21119d1931d238cebfb53107bf5e"
      resources :cpi_reg do

        desc '注册通知'
        params do
          requires :api_token, type: String
          requires :appid, type: String
          requires :reg_ip, type: String
          requires :bundle_name, type: String
          requires :app_platform, type: String
          requires :app_version, type: String
          requires :os_version, type: String
          requires :device_model, type: String
        end
        post 'reg_notice' do
          return {:error => 1, :detail => 'api_token错误'}  if params[:api_token] != CpiReg::ApiToken
          CpiReg.create_reg(params)
          present :error, 0
        end
      end
    end
  end
end
