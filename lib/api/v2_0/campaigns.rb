module API
  module V2_0
    class Campaigns < Grape::API
      resources :campaigns
        before do
          action_name =  @options[:path].join("")
          authenticate! if action_name != ':id'
        end

        #获取活动信息 根据
        params do
          requires :id, type: Integer
          optional :invitee_page, type: Integer
        end
        get ':id' do
          campaign = Campaign.find_by(id: params[:id])

          return error_403!({error: 1, detail: '该活动不存在' }) unless campaign

          campaign_invite = campaign.get_campaign_invite(current_kol.id)
          invitees_count, campaign_invites = CampaignInvite.get_invitees(params[:id], params[:invitee_page])

          present :error,           0
          present :campaign_invite, campaign_invite, with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
          present :invitees_count,  invitees_count
          present :invitees,        campaign_invites.collect{|t| t.kol}, with: API::V1::Entities::KolEntities::InviteeSummary
          present :put_switch,      $redis.get('put_switch') # 1:显示， 0:隐藏
          present :put_count,       $redis.get('put_count')
          present :leader_club,     current_kol.club.club_name
          # big_v
          present :big_v,           current_kol, with: API::V1_6::Entities::BigVEntities::Detail
          present :kol_shows,       current_kol.kol_shows, with: API::V1_6::Entities::KolShowEntities::Summary
          present :kol_keywords,    current_kol.kol_keywords, with: API::V1_6::Entities::KolKeywordEntities::Summary
          present :social_accounts, current_kol.social_accounts, with: API::V1_6::Entities::SocialAccountEntities::Summary
          present :is_follow,       current_kol.is_follow?(current_kol)
        end

      end
    end
  end
end
