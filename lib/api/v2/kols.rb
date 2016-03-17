module API
  module V2
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        put 'recal_score' do
          current_kol.reset_kol_uuid
          current_kol.reload
          present :error, 0
          present :kol_uuid, current_kol.kol_uuid
        end

        # #用户绑定第三方账号
        # params do
        #   requires :provider, type: String, values: ['weibo', 'wechat']
        #   requires :uid, type: String
        #   requires :token, type: String
        #   optional :name, type: String
        #   optional :url, type: String
        #   optional :avatar_url, type: String
        #   optional :desc, type: String
        #   optional :serial_params, type: String
        #   optional :followers_count, Integer
        #   optional :statuses_count, Integer
        #   optional :registered_at, Time
        #   optional :verified, :boolean
        #   optional :refresh_token, :string
        #   optional :unionid, type: String
        # end
        # post 'identity_bind' do
        #   identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
        #   #兼容pc端 wechat
        #   identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid])  if params[:unionid]
        #   if identity.blank?
        #     Identity.create_identity_from_app(params.merge(:from_type => 'app', :kol_id => kol.id))
        #     # 如果绑定第三方账号时候  kol头像不存在  需要同步第三方头像
        #     kol.update_attribute(:remote_avatar_url, params[:avatar_url])   if params[:avatar_url].present? && current_kol.avatar.url.blank?
        #     present :error, 0
        #     present :identities, current_kol.identities, with: API::V1::Entities::IdentityEntities::Summary
        #   else
        #     return error_403!({error: 1, detail: '该账号已经被绑定！'})
        #   end
        # end
      end
    end
  end
end
