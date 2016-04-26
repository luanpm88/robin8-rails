# encoding: utf-8

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

          @campaign = @campaign_apply.campaign

          return error_unprocessable! "已超过预计招募人数" if declared(params)[:operation] == 'agree' and @campaign.brand_passed_applies.count >= @campaign.recruit_person_count

          @campaign_apply.brand_pass_kol if declared(params)[:operation] == 'agree'
          @campaign_apply.brand_reject_kol if declared(params)[:operation] == 'cancel'
          present @campaign_apply
        end

        get '/' do
          @campaign = Campaign.find_by :id => params[:campaign_id]
          @campaign_applies = @campaign.valid_applies({:include => :kol})
          present @campaign_applies
        end
      end
    end
  end
end
