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
      end
    end
  end
end
