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
          binding.pry
          campaign = Campaign.find_by :id => params[:campaign_id], :user_id => current_user.id
          campaign_invites = paginate(Kaminari.paginate_array(campaign.valid_invites({:include => :kol })))
          present campaign_invites
        end
      end
    end
  end
end
