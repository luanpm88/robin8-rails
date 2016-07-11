module API
  module V1_3
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        params do
          requires :app_platform, type: String
          requires :app_version, type: String
          requires :os_version, type: String
          requires :device_model, type: String
          optional :city_name, type: String
          optional :IDFA, type: String
          optional :IMEI, type: String
        end
        put 'update_profile' do
          present :error, 0
          current_kol.reg_or_sign_in(params)
        end

        get 'alipay' do
          present :error, 0
          present :alipay_name, current_kol.alipay_name
          present :alipay_account, current_kol.alipay_account
          present :can_update_alipay, current_kol.can_update_alipay
          present :id_card, current_kol.id_card
        end

        params do
          requires :alipay_account, type: String
          requires :alipay_name, type: String
          optional :id_card, type: String
        end
        put 'bind_alipay' do
          present :error, 0
          current_kol.update_columns(:alipay_account => params[:alipay_account], :alipay_name => params[:alipay_name],
                                     :id_card => params[:id_card])
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
          # present :alipay_name, current_kol.alipay_name
          # present :alipay_account, current_kol.alipay_account
          # present :id_card, current_kol.id_card
          # present :can_update_alipay, current_kol.can_update_alipay
        end
      end
    end
  end
end
