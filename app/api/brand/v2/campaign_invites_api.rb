module Brand
  module V2
    class CampaignInvitesAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :campaign_invites do
        params do
          requires :campaign_id, type: Integer
        end
        get "/" do
          # 需要考虑 以管理员的身份 查看 campaign 详情的 需求
          campaign = Campaign.find_by :id => params[:campaign_id], :user_id => current_user.id
          campaign_invites = campaign ?  paginate(Kaminari.paginate_array(campaign.valid_invites({:include => :kol }))) : []
          present campaign_invites, with: Entities::CampaignInvite
        end

      end
    end
  end
end
