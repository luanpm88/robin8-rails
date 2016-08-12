module Brand
  module V1
    class CampaignMaterialsAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :campaign_materials do
        paginate per_page: 4
        get "/" do
          # 需要考虑 以管理员的身份 查看 campaign 详情的 需求
          campaign = Campaign.find_by :id => params[:campaign_id], :user_id => current_user.id
          campaign_invites = campaign ?  paginate(Kaminari.paginate_array(campaign.valid_invites({:include => :kol }))) : []
          present campaign_invites
        end

        params do
          requires :url_type, type: String
          requires :url, type:String
        end

        post '/' do
          campaign_material = CampaignMaterial.create!(url_type: declared(params)[:url_type], url: declared(params)[:url])
          present campaign_material
        end

      end
    end
  end
end
