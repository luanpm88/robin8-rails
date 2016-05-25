module API
  module V1_3
    class WeiboReport < Grape::API
      resources :weibo_report do
        before do
          authenticate!
        end

        params do
          requires :identity_id, type: Integer
        end
        get 'primary' do
          if params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeiboReport.primary_data
          else
            identity = current_kol.analysis_identities.find params[:identity_id]
            return {:error => 1, :detail => '分析的账户不存在'}                                 if  identity.blank?
            return {:error => 3, :detail => '授权过期，请重新授权'}                             if !identity.valid_authorize?
            res = identity.get_weibo_info( {:data_overview => 1}, 1)
            res = JSON.parse res
          end
          if res['status']
            present :error, 0
            present :primary, res['data']['overview'], with: API::V1_3::Entities::WeiboReportEntities::Primary
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
          requires :duration, type: Integer, values: [7,30,90], default: 30
        end
        get 'follower_follow' do
          if params[:identity_id] > 10000000
            incremental_total_count, incremental_avg_count,incremental_followers,decremental_followers, decremental_follower_list = IdentityAnalysis::FakeWeiboReport.follower_follow_data
            present :error, 0
            present :incremental_total_count, incremental_total_count
            present :incremental_avg_count,  incremental_avg_count
            present :incremental_followers, incremental_followers, with: API::V1_3::Entities::WeiboReportEntities::Follower
            present :decremental_followers, decremental_followers, with: API::V1_3::Entities::WeiboReportEntities::Follower
            present :decremental_follower_list, decremental_follower_list, with: API::V1_3::Entities::WeiboReportEntities::FollowerDetail
            return
          else
            identity = current_kol.analysis_identities.find params[:identity_id]
            return {:error => 1, :detail => '分析的账户不存在'}                                 if  identity.blank?
            return {:error => 3, :detail => '授权过期，请重新授权'}                              if !identity.valid_authorize?
            res = identity.get_weibo_info( {:incremental_follower => 1, :decremental_follower => 1}, params[:duration])
            res = JSON.parse res
          end
          if res['status']
            incremental_followers = AnalysisIdentity.complete_follower_data(res['data']['incremental_followers'], params[:duration])
            decremental_followers = AnalysisIdentity.complete_follower_data(res['data']['decremental_followers'], params[:duration])
            incremental_total_count, incremental_avg_count =  AnalysisIdentity.cal_follower_change(res['data']['incremental_followers'], params[:duration])
            decremental_follower_list = res['data']['decremental_followers'].collect{|t| t['users']}.compact.flatten  rescue  []
            present :error, 0
            present :incremental_total_count, incremental_total_count
            present :incremental_avg_count,  incremental_avg_count
            present :incremental_followers, incremental_followers, with: API::V1_3::Entities::WeiboReportEntities::Follower
            present :decremental_followers, decremental_followers, with: API::V1_3::Entities::WeiboReportEntities::Follower
            present :decremental_follower_list, decremental_follower_list, with: API::V1_3::Entities::WeiboReportEntities::FollowerDetail
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
        end
        get 'follower_verified' do
          if params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeiboReport.follower_verified_data
          else
            identity = current_kol.analysis_identities.find params[:identity_id]
            return {:error => 1, :detail => '分析的账户不存在'}                                 if  identity.blank?
            return {:error => 3, :detail => '授权过期，请重新授权'}                              if !identity.valid_authorize?
            res = JSON.parse identity.get_weibo_info({:sorted_follower => 1}, 1)  rescue {}
          end
          if res['status']
            present :error, 0
            present :follower_verified, res['data']['sorted_followers'].first, with: API::V1_3::Entities::WeiboReportEntities::FollowerVerified
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
          requires :duration, type: Integer, values: [7,30,90], default: 30
        end
        get 'friend_verified' do
          if params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeiboReport.friend_verified_data
          else
            identity = current_kol.analysis_identities.find params[:identity_id]
            return {:error => 1, :detail => '分析的账户不存在'}                                 if  identity.blank?
            return {:error => 3, :detail => '授权过期，请重新授权'}                             if !identity.valid_authorize?
            res = JSON.parse identity.get_weibo_info( {:sorted_friend => 1, :bilateral_friendship => 1}, params[:duration])  rescue {}
          end
          if res['status']
            sorted_friends = AnalysisIdentity.complete_sorted_friends(res['data']['sorted_friends'], params[:duration])
            present :error, 0
            present :friend_verified, sorted_friends, with: API::V1_3::Entities::WeiboReportEntities::FriendVerified
            present :bilateral, res['data']['bilateral_friendships'].first, with: API::V1_3::Entities::WeiboReportEntities::Bilateral
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
        end
        get 'follower_profile' do
          if params[:identity_id] > 10000000
            res = IdentityAnalysis::FakeWeiboReport.follower_profile_data
          else
            identity = current_kol.analysis_identities.find params[:identity_id]
            return {:error => 1, :detail => '分析的账户不存在'}                 if  identity.blank?
            return {:error => 3, :detail => '授权过期，请重新授权'}             if !identity.valid_authorize?
            res = JSON.parse identity.get_weibo_info( {:regional_follower => 1, :sexual_follower => 1}, 1)  rescue {}
          end
          puts res
          if res['status']
            present :error, 0
            present :regions, res['data']['regional_followers'].first['regions'], with: API::V1_3::Entities::WeiboReportEntities::Region
            present :genders, res['data']['sexual_followers'].first, with: API::V1_3::Entities::WeiboReportEntities::Gender
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end

        params do
          requires :identity_id, type: Integer
        end
        get 'statuses' do
          if params[:identity_id] > 10000000
            puts "======="
            res = IdentityAnalysis::FakeWeiboReport.statuses_data
          else
            identity = current_kol.analysis_identities.find params[:identity_id]
            return {:error => 1, :detail => '分析的账户不存在'}                if  identity.blank?
            return {:error => 3, :detail => '授权过期，请重新授权'}             if !identity.valid_authorize?
            res = JSON.parse identity.get_weibo_info( {:user_timeline => 1})  rescue {}
          end
          puts res
          if res['status']
            present :error, 0
            present :statuses, res['data']['statuses'], with: API::V1_3::Entities::WeiboReportEntities::Status
          else
            present :error, 1
            present :detail, '请求错误，请稍后再试'
          end
        end
      end
    end
  end
end
