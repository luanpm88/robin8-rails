module API
  module V1
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
          params[:gender] = params[:gender].to_i    if params[:gender].present?
        end

        # 用户上传头像
        post 'upload_avatar' do
          params[:avatar] = Rack::Test::UploadedFile.new(File.open("#{Rails.root}/app/assets/images/100.png"))  if Rails.env.development?
          required_attributes! [:avatar]
          current_kol.avatar = params[:avatar]
          if current_kol.save
            return {:error => 0, :avatar_url =>  (current_kol.avatar.url rescue '') }
          else
            error_403!({error: 1, detail: errors_message(current_kol)})
          end
        end

        get 'account' do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Account
        end

        get 'profile'  do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
        end

        params do
          optional :gender, type: Integer, values: [0, 1, 2]
          optional :tags, type: Array[String]
        end
        put 'update_profile' do
          # attribute_must_in(:gender, params[:gender].to_i, [0, 1, 2])     if params[:gender]
          attrs = attributes_for_keys [:name, :gender, :date_of_birthday,
                                       :app_country, :app_province, :app_city, :desc, :alipay_account]
          if params[:tags] && params[:tags].size > 0
            kol_tags = Tag.where(:name => params[:tags])
            current_kol.tags = kol_tags
          end
          current_kol.attributes = attrs
          if current_kol.save
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
