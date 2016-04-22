module Brand
  module V1
    class CampaignAppliesAPI < Base
      before do
        authenticate!
      end

      resource :campaign_applies do
        params do
          requires :campaign_id , type: Integer
          requires :kol_id      , type: Integer
          requires :operation   , type: String
        end
        put "change_status" do
          @campaign_apply = CampaignApply.find_by :campaign_id => declared(params)[:campaign_id], :kol_id => declared(params)[:kol_id]
          @campaign_apply.brand_pass_kol if declared(params)[:operation] == 'agree'
          @campaign_apply.brand_reject_kol if declared(params)[:operation] == 'cancel'
        end
      end
    end
  end
end
