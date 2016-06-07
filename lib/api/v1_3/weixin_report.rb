module API
  module V1_3
    class WeixinReport < Grape::API
      resources :weixin_report do
        before do
          authenticate!
          @identity = AnalysisIdentity.find(params[:identity_id])    rescue nil
        end

        params do
          optional :identity_id, type: Integer
          optional :login_id, type: Integer
        end
        get 'primary' do
          if params[:identity_id].present? && params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeixinReport.primary_data
          else
            if params[:login_id]
              login = PublicWechatLogin.find params[:login_id]  rescue nil
            else
              return {:error => 1, :detail => '分析的账户不存在'}                   if @identity.blank?
              return {:error => 3, :detail => '授权过期，请重新授权'}                if !@identity.valid_authorize?
              login = @identity.newest_login
            end
            res = JSON.parse login.get_info     rescue {}
            login.sync_info_to_identity(res['data']['user'])
          end
          if res && res['status']
            present :error, 0
            present :primary, res['data']['user'], with: API::V1_3::Entities::WeixinReportEntities::Primary
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          optional :identity_id, type: Integer
          optional :login_id, type: Integer
          at_least_one_of :identity_id, :login_id,  message: "login_id identity_id 必须存在一个"
        end
        get 'messages' do
          if params[:identity_id].present? && params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeixinReport.messages_data
          else
            if params[:login_id]
              login = PublicWechatLogin.find params[:login_id]  rescue nil
            else
              return {:error => 1, :detail => '分析的账户不存在'}                   if @identity.blank?
              return {:error => 3, :detail => '授权过期，请重新授权'}                if !@identity.valid_authorize?
              login = @identity.newest_login
            end
            res = JSON.parse login.get_info('messages')  rescue {}
            puts res
          end
          if res && res['status']
            present :error, 0
            present :messages, res['data']['messages'], with: API::V1_3::Entities::WeixinReportEntities::Message
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end


        params do
          optional :identity_id, type: Integer
          optional :login_id, type: Integer
          at_least_one_of :identity_id, :login_id,  message: "login_id identity_id 必须存在一个"
        end
        get 'articles' do
          if params[:identity_id].present? && params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeixinReport.articles_data
          else
            if params[:login_id]
              login = PublicWechatLogin.find params[:login_id]  rescue nil
            else
              return {:error => 1, :detail => '分析的账户不存在'}                   if @identity.blank?
              return {:error => 3, :detail => '授权过期，请重新授权'}                if !@identity.valid_authorize?
              login = @identity.newest_login
            end
            res = JSON.parse login.get_info('articles')   rescue {}
            puts res
          end
          if res && res['status']
            present :error, 0
            present :articles, res['data']['articles'], with: API::V1_3::Entities::WeixinReportEntities::Article
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end


        params do
          optional :identity_id, type: Integer
          optional :login_id, type: Integer
          at_least_one_of :identity_id, :login_id,  message: "login_id identity_id 必须存在一个"
        end
        get 'user_analysises' do
          if params[:identity_id].present? && params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeixinReport.user_analysises_data
          else
            if params[:login_id]
              login = PublicWechatLogin.find params[:login_id]  rescue nil
            else
              return {:error => 1, :detail => '分析的账户不存在'}                   if @identity.blank?
              return {:error => 3, :detail => '授权过期，请重新授权'}                if !@identity.valid_authorize?
              login = @identity.newest_login
            end
            res = JSON.parse login.get_info('user_analysises')   rescue {}
          end
          if res && res['status']
            present :error, 0
            present :user_analysises, res['data']['user_analysises'], with: API::V1_3::Entities::WeixinReportEntities::UserAnalysise
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

      end
    end
  end
end
