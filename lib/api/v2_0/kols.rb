# coding: utf-8
module API
  module V2_0
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

        get 'overview' do
          present :error, 0
          present :unread_messages_count, current_kol.unread_messages.count
          present :total_income, current_kol.total_income.round(2)
          # 签到
          present :continuous_checkin_count, current_kol.continuous_checkin_count
          present :today_had_check_in, current_kol.today_had_check_in?
          # 活动分享
          present :campaigns, current_kol, with: API::V2_0::Entities::KolOverviewEntities::Campaigns
          # 产品分享
          present :cps_share, current_kol, with: API::V2_0::Entities::KolOverviewEntities::CpsShare
          # 邀请 KOL
          present :kol_invitations, current_kol, with: API::V2_0::Entities::KolOverviewEntities::KolInvitations
        end

        params do
          requires :provider, type: String, values: ['weibo', 'wechat']
        end
        post 'calculate_influence_score' do
          kol_identity = current_kol.identities.where(provider: params[:provider]).first rescue nil

          unless current_kol.influence_metrics.any?
            if params[:provider] == 'weibo'
              KolInfluenceMetricsWorker.perform_async [kol_identity.uid], []
            else
              KolInfluenceMetricsWorker.perform_async [], [kol_identity.uid]
            end
          end
          present :error, 0
        end

        get 'influence_score' do
          kol_metric = current_kol.influence_metrics.first
          kol_identity = current_kol.identities.where(provider: 'weibo').first rescue nil

          unless kol_metric or kol_metric.try(:calculated) == true or kol_identity
            present :error, 0
            present :calculated, false
            present :time, 10
          else
            present :error, 0
            present :calculated, kol_metric.calculated
            present :provider, kol_metric.provider
            present :avatar_url, kol_identity.avatar_url
            present :name, kol_identity.name
            present :description, kol_identity.desc
            present :influence_score, kol_metric.influence_score
            present :influence_level, kol_metric.influence_level
            present :influence_score_percentile, kol_metric.influence_score_percentile
            present :calculated_date, kol_metric.updated_at.strftime('%Y-%m-%d')
            present :avg_posts, kol_metric.avg_posts
            present :avg_comments, kol_metric.avg_comments
            present :avg_likes, kol_metric.avg_likes
            present :industries, kol_metric.influence_industries, with: API::V2_0::Entities::InfluenceEntities::Industries
          end
        end
      end
    end
  end
end
