module API
  module V1
    class Kols < Grape::API
      resources :kols do
        # 用户上传头像
        post 'avatar' do
          authenticate!
          params[:avatar] = Rack::Test::UploadedFile.new(File.open("#{Rails.root}/app/assets/images/100.png"))  if Rails.env.development?
          required_attributes! [:avatar]
          current_kol.avatar = params[:avatar]
          if current_kol.save
            return {:error => 0, :avatar_url =>  current_kol.avatar.url(200) }
          else
            error_403!({error: 1, detail: errors_message(current_kol)})
          end
        end

        get 'account' do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Account
        end

        put 'update_profile' do
          authenticate!
          # required_attributes! [:name, :gender, :date_of_birthday,
          #                       :country, :province, :city, :desc, :tags, :alipay_account]
          requires :gender, type: String, values: [0, 1, 2]   if params[:gender].present?
          attrs = attributes_for_keys [:name, :gender, :date_of_birthday,
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
