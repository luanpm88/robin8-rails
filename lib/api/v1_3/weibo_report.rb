module API
  module V1_3
    class WeiboReport < Grape::API
      resources :weibo_report do
        # before do
        #   authenticate!
        # end

        params do
          requires :identity_id, type: Integer
        end
        get 'primary' do
        end

        params do
          requires :identity_id, type: Integer
          requires :duration, type: Integer, values: [7,30,90]
        end
        get 'followers' do
          identity = AnalysisIdentity.find params[:identity_id]
          res = JSON.parse identity.get_weibo_info(params[:duration], {:bilateral_friendship => 1, :decremental_follower => 1} )  rescue {}
          if res['status']
            present :error, 1
            present :messages, res['data']['messages'], with: API::V1_3::Entities::WeixinReportEntities::Message
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end


        params do
          requires :login_id, type: Integer
        end
        get 'articles' do
          login = PublicWechatLogin.find params[:login_id]
          res = JSON.parse login.get_info('articles')   rescue {}
          puts res
          if res['status']
            present :error, 1
            present :articles, res['data']['articles'], with: API::V1_3::Entities::WeixinReportEntities::Article
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end


        params do
          requires :login_id, type: Integer
        end
        get 'user_analysises' do
          login = PublicWechatLogin.find params[:login_id]
          res = JSON.parse login.get_info('user_analysises')   rescue {}
          if res['status']
            present :error, 1
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
