# coding: utf-8
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
          present :had_complete_reward, current_kol.had_complete_reward?
          present :can_receive_complete_reward, current_kol.can_receive_complete_reward
        end

        params do
          optional :gender, type: Integer, values: [0, 1, 2]
          # optional :tags, type: Array[String]
        end
        put 'update_profile' do
          attrs = attributes_for_keys [:name, :gender, :date_of_birthday, :age, :weixin_friend_count,
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
              current_kol.update_column(:name, Kol.hide_real_mobile_number(params[:mobile_number]))    if current_kol.name.blank?
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
              current_kol.update_column(:name, Kol.hide_real_mobile_number(params[:mobile_number]))    if current_kol.name.blank?
              current_kol.reset_private_token
              present :error, 0
              present :kol, current_kol, with: API::V1::Entities::KolEntities::Summary
            end
          end
        end

        #第三方账号列表
        get 'identities' do
          present :error, 0
          present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
        end

        #用户绑定第三方账号
        params do
          requires :provider, type: String, values: ['weibo', 'wechat', 'qq']
          requires :uid, type: String
          requires :token, type: String
          optional :name, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :serial_params, type: String
          optional :followers_count, Integer
          optional :statuses_count, Integer
          optional :registered_at, DateTime
          optional :verified, :boolean
          optional :refresh_token, :string
          optional :unionid, type: String

          optional :province, type: String
          optional :city, type: String
          optional :gender, type: String
          optional :is_vip, type: Boolean
          optional :is_yellow_vip, type: Boolean
          optional :bind_type, type: String
        end
        post 'identity_bind' do
          identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
          #兼容pc端 wechat
          identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid])  if identity.blank? && params[:unionid]

          if identity
            time_gap = Time.now.strftime("%j").to_i - identity.updated_at.strftime("%j").to_i
            return error_403!({error: 1, detail: "每次解绑后须30天才能重新绑定,距离下次解绑还剩#{30 - time_gap}天"})  if time_gap < 30
          elsif identity.blank? || identity.token.blank?
            Identity.create_identity_from_app(params.merge(:from_type => 'app', :kol_id => current_kol.id), identity)
            current_kol.update_attribute(:avatar_url, params[:avatar_url])   if params[:avatar_url].present? && current_kol.avatar_url.blank?
            present :error, 0
            present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
          elsif identity.kol_id == current_kol.id
            return error_403!({error: 1, detail: '您已经绑定了该账号!'})
          else
              Identity.create_identity_from_app(params.merge(:from_type => 'app', :kol_id => current_kol.id), identity)
              present :error, 0
              present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
            end
          end
        end

        params do
          requires :uid, type: String
        end
        put 'identity_unbind' do
          identity = current_kol.identities.where(:uid => params[:uid]).first   rescue nil
          if identity
            identity.update(token: nil)
            current_kol.reload
            present :error, 0
            present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
          else
            return error_403!({error: 1, detail: '未找到该第三方账号信息'})
          end
        end

        #设置城市
        params do
          requires :city_name, type: String
        end
        put 'set_city' do
          city = City.where("name like '#{params[:city_name]}%'").first   rescue nil
          current_kol.update_column(:app_city, city.name_en)
          present :error, 0
        end

        params do
          requires :kol_id, type: Integer
        end
        get 'common' do
          kol = Kol.find  params[:kol_id]
          return error_403!({error: 1, detail: '未找到该用户'}) if kol.blank?
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Info
        end
      end
    end
  end
end
