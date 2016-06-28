module API
  module V1_4
    class CpiReg < Grape::API
      resources :cpi_reg do

        desc '注册通知'
        params do
          requires :bundle_name, type: String
          requires :app_platform, type: String
          requires :app_version, type: String
          requires :os_version, type: String
          requires :device_model, type: String
          requires :encryption_data, type: String
        end
        post 'reg_notice' do
          decry_data = AuthToken.decry_cpi_data(params[:encryption_data])
          if ::CpiReg.valid_data?(decry_data) == false
            present :error, 1
            present :detail, '数据格式不对'
          elsif ::CpiReg.had_reg?(decry_data)
            ::CpiReg.create_reg(params, decry_data, ::CpiReg::AlreadRegStatus)
            present :error, 1
            present :detail, '该用户已经注册'
          else
            params[:reg_ip] = request.ip    #override
            ::CpiReg.create_reg(params, decry_data)
            present :error, 0
          end
        end
      end
    end
  end
end
