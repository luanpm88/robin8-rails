module API
  module V1
    class Kols < Grape::API
      resources :kols do
        authenticate!
        # 用户上传头像
        post 'avatar' do
          required_attributes! [:avatar]
          current_kol.avatar = params[:avatar]
          if current_kol.save
            present :error, 0
            present :user, current_user, with: API::V1::Entities::UserEntities::Summary
          else
            error_403!({error: 1, detail: errors_message(current_kol)})
          end
        end

        get 'account' do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Account
        end

        put 'update_profile' do
          required_attributes! [:first_name, :last_name, :gender, :date_of_birthday,
                                :country, :province, :city, :desc, :tags, :alipay_account]
          attrs = attributes_for_keys [:first_name, :last_name, :gender, :date_of_birthday,
                                       :country, :province, :city, :desc, :tags, :alipay_account]
          if current_kol.update_attributes(attrs)
            present :error, 0
            present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
          else
            error_403!({error: 1, detail: errors_message(current_kol)})
          end
        end
      end
    end
  end
end
