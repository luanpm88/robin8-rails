# encoding: utf-8

module Brand
  module V1
    class CampaignAppliesAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :campaign_applies do
        params do
          requires :campaign_id , type: Integer
          requires :kol_id      , type: Integer
          requires :status   , type: String
        end
        put "change_status" do

          @campaign_apply = CampaignApply.find_by :campaign_id => declared(params)[:campaign_id], :kol_id => declared(params)[:kol_id]

          @campaign = @campaign_apply.campaign
          if declared(params)[:status] == 'brand_passed'
            return error_unprocessable! "已超过预计招募人数" if @campaign.brand_passed_applies.count >= @campaign.recruit_person_count
            @campaign_apply.brand_pass_kol
          elsif declared(params)[:status] == 'brand_rejected'
            @campaign_apply.brand_reject_kol
          elsif declared(params)[:status] == 'platform_passed'
            @campaign_apply.brand_cancel_kol
          end
          present @campaign_apply
        end

        # params do
        #   requires :campaign_id , type: Integer
        # end
        put ":id/pass_all_kols" do
          @campaign = Campaign.find_by :id => params[:id]
          @campaign_applies = @campaign.campaign_applies
          if  @campaign_applies.size > @campaign.recruit_person_count
            return error_unprocessable! "当前报名人数超过招募人数，不能全部通过！"
          else
            @campaign_applies.update_all(status: 'brand_passed')
          end

          present @campaign_applies
        end

        get '/' do
          @campaign = Campaign.find_by :id => params[:campaign_id]
          @campaign_applies = @campaign ? paginate(Kaminari.paginate_array(@campaign.valid_applies.includes(:kol, :campaign_invite))) : []

          
          present @campaign_applies
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
          present campaign_invite.campaign_apply
        end
      end
    end
  end
end
