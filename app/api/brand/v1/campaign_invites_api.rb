module Brand
  module V1
    class CampaignInvitesApi < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :campaign_invites do
        paginate per_page: 4
        get "/" do
          # 需要考虑 以管理员的身份 查看 campaign 详情的 需求
          campaign = Campaign.find_by :id => params[:campaign_id], :user_id => current_user.id
          campaign_invites = campaign ?  paginate(Kaminari.paginate_array(campaign.valid_invites({:include => :kol }))) : []
          present campaign_invites
        end

        params do
          requires :campaign_id, type: Integer
          requires :kol_id, type: Integer
          requires :score, type: String
          requires :opinion, type: String
        end
        put 'update_score_and_opinion' do
          campaign_invite = CampaignInvite.find_by campaign_id: declared(params)[:campaign_id], kol_id: declared(params)[:kol_id]
          campaign_invite.update kol_score: declared(params)[:score], brand_opinion: declared(params)[:opinion]
          present campaign_invite
        end
      end
    end
  end
end
