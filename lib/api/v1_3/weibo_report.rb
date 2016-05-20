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
        get 'follower_follow' do
          identity = AnalysisIdentity.find params[:identity_id]
          res = identity.get_weibo_info( {:incremental_followers => 1, :decremental_followers => 1}, params[:duration])  rescue {}
          res = JSON.parse res
          if res['status']
            present :error, 1
            present :incremental_followers, res['data']['incremental_followers'], with: API::V1_3::Entities::WeiboReportEntities::Follower
            present :decremental_followers, res['data']['decremental_followers'], with: API::V1_3::Entities::WeiboReportEntities::Follower
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
        end
        get 'follower_verified' do
          identity = AnalysisIdentity.find params[:identity_id]
          res = JSON.parse identity.get_weibo_info( {:sorted_follower => 1}, 1)  rescue {}
          if res['status']
            present :error, 1
            present :follower_verified, res['data']['sorted_friend'].first, with: API::V1_3::Entities::WeiboReportEntities::Verified
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
          requires :duration, type: Integer, values: [7,30,90]
        end
        get 'friend_verified' do
          identity = AnalysisIdentity.find params[:identity_id]
          res = JSON.parse identity.get_weibo_info( {:sorted_friend => 1, :bilateral_friendships => 1}, params[:duration])  rescue {}
          if res['status']
            present :error, 1
            present :friend_verified, res['data']['sorted_friend'], with: API::V1_3::Entities::WeiboReportEntities::FriendVerified
            present :bilateral_friendships, res['data']['bilateral_friendships'].first, with: API::V1_3::Entities::WeiboReportEntities::Bilateral
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
        end
        get 'statuses' do
          identity = AnalysisIdentity.find params[:identity_id]
          res = JSON.parse identity.get_weibo_info( {:statuses => 1}, 7)  rescue {}
          if res['status']
            present :error, 1
            present :statuses, res['data']['statuses'], with: API::V1_3::Entities::WeiboReportEntities::Statuses
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end
      end
    end
  end
end
