module API
  module V1_3
    class AnalysisIdentities < Grape::API
      resources :analysis_identities do
        before do
          authenticate!
        end

        get 'list' do
          identities = current_kol.analysis_identities.to_a
          present :error, 0
          present :identities, identities,  with: API::V1_3::Entities::AnalysisIdentityEntities::Summary
        end

        params do
          requires :provider, type: String, values: ['weibo']
          requires :uid, type: String
          requires :name, type: String
          requires :avatar_url, type: String
          requires :access_token, type: String
          requires :refresh_token, type: String
          requires :location, type: String
          requires :gender, type: String
          requires :serial_params, type: String
          requires :bind_type, type: String, values: ['bind', 'update']
        end
        put 'identity_bind' do
          identity = AnalysisIdentity.find_by(:kol_id => current_kol.id, :uid => params[:uid])
          if params[:bind_type] == 'bind'
            if identity.blank?
              identity =  AnalysisIdentity.new
              identity.kol_id = current_kol.id
              attrs = attributes_for_keys [:provider, :uid, :name, :avatar_url, :access_token,
                                           :refresh_token, :location, :gender, :serial_params]
              identity.attributes = attrs
              identity.authorize_time = Time.now
              identity.save
              present :error, 0
              present :identities, current_kol.analysis_identities, with:API::V1_3::Entities::AnalysisIdentityEntities::Summary
            else
              return error_403!({error: 1, detail: '您已绑定过改账号！'})
            end
          else
            identity.access_token = params[:access_token]
            identity.refresh_token = params[:refresh_token]
            identity.authorize_time = Time.now
            identity.save
            present :error, 0
            present :identities, current_kol.analysis_identities, with: API::V1_3::Entities::AnalysisIdentityEntities::Summary
          end
        end

        params do
          optional :identity_id, type: String
          optional :login_id, type: Integer
        end
        put 'identity_unbind' do
          if params[:identity_id].present?
            identity = AnalysisIdentity.find params[:identity_id]        rescue nil
          else
            login = PublicWechatLogin.find(params[:login_id])            rescue nil
            identity = AnalysisIdentity.find_by :name => login.username    rescue nil
          end
          if identity
            identity.delete
            present :error, 0
            present :detail, '解绑成功'
          else
            return error_403!({error: 1, detail: '该账号不存在'})
          end
        end

        params do
          requires :id, type: Integer
        end
        get 'check_authorize' do
          identity = AnalysisIdentity.find params[:id]
          if identity.blank?
            return error_403!({error: 1, detail: '该账号不存在！'})
          else
            present :error, 0
            present :valid, identity.valid_authorize?
          end
        end
      end
    end
  end
end
