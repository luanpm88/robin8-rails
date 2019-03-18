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
          # kol_identity = current_kol.identities.where(provider: params[:provider]).first rescue nil

          # unless current_kol.influence_metrics.any?
          #   if params[:provider] == 'weibo'
          #     KolInfluenceMetricsWorker.perform_async [kol_identity.uid], []
          #   else
          #     KolInfluenceMetricsWorker.perform_async [], [kol_identity.uid]
          #   end
          # end
          present :error, 0
        end

        get 'influence_score' do
          kol_metric = current_kol.influence_metrics.first rescue nil
          kol_identity = current_kol.identities.where(provider: 'weibo').first rescue nil
          calculated = kol_metric.calculated rescue nil

          if kol_metric and kol_identity and (calculated==true)
            industries = kol_metric.influence_industries rescue []

            present :error, 0
            present :influence_score_visibility, current_kol.influence_score_visibility
            present :calculated, kol_metric.calculated
            present :provider, kol_metric.provider
            present :avatar_url, kol_identity.avatar_url
            present :name, kol_identity.name
            present :description, kol_identity.desc
            present :influence_score, kol_metric.influence_score
            present :influence_level, kol_metric.influence_level
            present :influence_score_percentile, kol_metric.influence_score_percentile
            present :calculated_date, kol_metric.updated_at.strftime('%Y-%m-%d')
            present :avg_posts, kol_metric.avg_posts.round(2)
            present :avg_comments, kol_metric.avg_comments.round(2)
            present :avg_likes, kol_metric.avg_likes.round(2)

            if industries.any?
              present :industries, industries, with: API::V2_0::Entities::InfluenceEntities::Industries
              present :similar_kols, current_kol.similar_influence_kol_ids('weibo'), with: API::V2_0::Entities::InfluenceEntities::SimilarKols
            else
              present :industries, []
              present :similar_kols, []
            end

          else
            present :error, 0
            present :calculated, false
            present :time, 10
          end
        end

        params do
          requires :kol_id, type: Integer
        end
        get ':kol_id/similar_kol_details' do
          kol = Kol.find params[:kol_id] rescue nil
          if kol
            kol_metric = kol.influence_metrics.first
            kol_identity = kol.identities.where(provider: 'weibo').first rescue nil

            if kol_metric and (kol_metric.try(:calculated) == true) and kol_identity
              present :error, 0
              present :influence_score_visibility, kol.influence_score_visibility
              present :calculated, kol_metric.calculated
              present :provider, kol_metric.provider
              present :avatar_url, kol_identity.avatar_url
              present :name, kol_identity.name
              present :description, kol_identity.desc
              present :influence_score, kol_metric.influence_score
              present :influence_level, kol_metric.influence_level
              present :influence_score_percentile, kol_metric.influence_score_percentile
              present :calculated_date, kol_metric.updated_at.strftime('%Y-%m-%d')
              present :avg_posts, kol_metric.avg_posts.round(2)
              present :avg_comments, kol_metric.avg_comments.round(2)
              present :avg_likes, kol_metric.avg_likes.round(2)
              present :industries, kol_metric.influence_industries, with: API::V2_0::Entities::InfluenceEntities::Industries
              present :similar_kols, kol.similar_influence_kol_ids('weibo'), with: API::V2_0::Entities::InfluenceEntities::SimilarKols
            else
              present :error, 0
              present :calculated, false
              present :time, 10
            end
          else
            present :error, 1
            present :error_message, 'Kol or kol influence score data not found'
          end

        end

        params do
          requires :invite_code , type: Integer
        end
        post "invite_code" do
          result = check_invite_code(params[:invite_code] , true)
          return error_403!({error: 1, detail: result})   unless result == true
          current_kol.invite_code_dispose(params[:invite_code])
          present :error, 0
        end

        params do
          requires :action, type: String, values: ['on', 'off']
        end
        get 'manage_influence_visibility' do
          action = params[:action] == 'on' ? true : false
          current_kol.influence_score_visibility = action
          if current_kol.save
            present :error, 0
          else
            present :error, 1
          end
        end

        desc '徒弟列表'
        params do
          requires :page, type: Integer
        end
        get 'percentage_on_friend' do
          k_ids = current_kol.desc_percentage_on_friend
          select_ids = k_ids[(params[:page].to_i-1)*10..params[:page].to_i*10-1]
          _hash = {}
          current_kol.children.where(id: select_ids).each do |kol|
            _hash[kol.id] = {
              kol_id:                 kol.id,
              kol_name:               kol.name,
              avatar_url:             kol.avatar_url,
              campaign_invites_count: kol.campaign_invites.count,
              amount:                 current_kol.friend_amount(kol)
            }
          end
          list = []
          select_ids.each do |ele|
            list << _hash[ele]
          end
          present :error, 0
          present :total_count, k_ids.count
          present :total_pages, page_count(k_ids.count).to_i
          present :current_page, params[:page]
          present :list, list
        end

        desc '今日徒弟数'
        params do
          requires :page, type: Integer
        end
        get 'today_friends' do
          @kols = current_kol.children.recent(Time.now, Time.now).page(params[:page]).per_page(10)
          present :error, 0
          to_paginate(@kols)
          present :total_count, @kols.count
          present :list, @kols , with: API::V2_0::Entities::KolOverviewEntities::FriendsPercentage, current_kol: current_kol
        end

      end
    end
  end
end
