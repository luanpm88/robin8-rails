module API
  module V1
    class Kols < Grape::API
      resources :kols do
        before do
          action_name =  @options[:path].join("")
          authenticate! if action_name != 'sign_in'  &&  action_name != "oauth_login"
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
          present :stats, current_kol.recent_income
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
        params do
          requires :mobile_number, type: Integer, regexp: /\d{11}/
          requires :code, type: Integer
        end
        put 'update_mobile' do
          mobile_exist = Kol.find_by(:mobile_number => params[:mobile_number])
          if mobile_exist
            error_403!({error: 1, detail: '该手机已经绑定了其他账号！'})
          else
            if !YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
              return error_403!({error: 1, detail: '验证码与手机号码不匹配!'})
            else
              current_kol.update_column(:mobile_number, params[:mobile_number])
              current_kol.update_column(:name, params[:mobile_number])    if current_kol.name.blank?
              current_kol.reset_private_token
              present :error, 0
              present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
            end
          end
        end


        #第三方账号绑定手机号
        params do
          requires :mobile_number, type: Integer, regexp: /\d{11}/
          requires :code, type: Integer
        end
        put 'bind_mobile' do
          if !YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
            return error_403!({error: 1, detail: '验证码与手机号码不匹配!'})
          else
            mobile_kol = Kol.find_by(:mobile_number => params[:mobile_number])
            # 如果该手机号码在系统存在，此时需要把当前用户的identity 转移到mobil_kol身上，同时把当前用户删除
            if mobile_kol
              Identity.where(:kol_id => current_kol.id).update_all(:kol_id => mobile_kol.id)
              mobile_kol.reset_private_token
              present :error, 0
              present :kol, mobile_kol, with: API::V1::Entities::KolEntities::Summary
            else
              current_kol.update_column(:mobile_number, params[:mobile_number])
              current_kol.update_column(:name, params[:mobile_number])    if current_kol.name.blank?
              current_kol.reset_private_token
              present :error, 0
              present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
            end
          end
        end

        #第三方账号列表
        get 'identities' do
          present :error, 0
          present :identities, current_kol.identities.from_app, with: API::V1::Entities::IdentityEntities::Summary
        end

        #用户绑定第三方账号
        params do
          requires :provider, type: String, values: ['weibo', 'wechat']
          requires :uid, type: String
          requires :token, type: String
          optional :name, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :serial_params, type: JSON
        end
        post 'identity_bind' do
          identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
          if identity.blank?
            attrs = attributes_for_keys [:provider, :uid, :token, :name, :url, :avatar_url, :desc, :serial_params]
            identity = Identity.new
            identity.attributes = attrs
            identity.kol_id = current_kol.id
            identity.from_type = 'app'
            identity.save
            # 如果绑定第三方账号时候  kol头像不存在  需要同步第三方头像
            if params[:avatar_url].present? && current_kol.avatar.url.blank?
              kol.remote_avatar_url =  params[:avatar_url]
              kol.save
            end
            present :error, 0
            present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
          else
            return error_403!({error: 1, detail: '该账号已经被绑定！'})
          end
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
