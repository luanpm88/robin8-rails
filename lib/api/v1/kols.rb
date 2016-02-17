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
            return error_403!({error: 1, detail: errors_message(current_kol)})
          end
        end

        get 'account' do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Account
        end

        get 'primary' do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Primary
        end

        get 'profile'  do
          present :error, 0
          present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
        end

        params do
          optional :gender, type: Integer, values: [0, 1, 2]
          # optional :tags, type: Array[String]
        end
        put 'update_profile' do
          attrs = attributes_for_keys [:name, :gender, :date_of_birthday,
                                       :app_country, :app_province, :app_city, :desc, :alipay_account]
          current_kol.attributes = attrs
          if current_kol.save
            if params[:tags].present?
              kol_tags = Tag.where(:name => params[:tags].split(","))
              current_kol.tags = kol_tags
            end
            present :error, 0
            present :kol, current_kol.reload, with: API::V1::Entities::KolEntities::Summary
          else
            return error_403!({error: 1, detail: errors_message(current_kol)})
          end
        end


        #更换手机
        #第三方登陆后绑定手机
        params do
          requires :mobile_number, type: Integer, regexp: /\d{11}/
          requires :code, type: Integer, regexp: /\d{6}/
        end
        put 'update_mobile' do
          kol = Kol.find_by :mobile_number => params[:mobile_number]
          if kol
            error_403!({error: 1, detail: '该手机已经绑定了其他账号！'})
          else
            if !YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
              return error_403!({error: 1, detail: '验证码与手机号码不匹配!'})
            else
              current_kol.update_column(:mobile_number, params[:mobile_number])
              current_kol.reset_private_token
              present :error, 0
              present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
              # return {:error => 0, :detail => '更换成功'}
            end
          end
        end

        #第三方账号列表
        get 'identities' do
          present :error, 0
          present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #第三方账号解除绑定
        params do
          requires :uid, type: String
        end
        put 'identity_unbind' do
          identity = current_kol.identities.where(:uid => params[:uid]).first   rescue nil
          if identity
            identity.delete
            current_kol.reload
            present :error, 0
            present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
          else
            return error_403!({error: 1, detail: '未找到该第三方账号信息'})
          end
        end

      end
    end
  end
end
