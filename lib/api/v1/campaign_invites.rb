module API
  module V1
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['all', 'running', 'approved' ,'verifying', 'settled', 'liked']
        end
        get 'list' do
          if params[:status] == 'like'
            like_campaign_ids = current_user.love_campaign_likes.collect{|t| t.campaign_id }
            @campaign_invites = current_kol.campaign_invites.where(:campaign_id => like_campaign_ids )
          else
            hide_campaign_ids = current_kol.hide_campaign_likes.collect{|t| t.campaign_id }
            if params[:status] == 'all'
              @campaign_invites = current_kol.campaign_invites.where.not(:campaign_id => hide_campaign_ids).where.not(:status => 'rejected')
            else
              @campaign_invites = current_kol.campaign_invites.send(params[:status]).where.not(:campaign_id => hide_campaign_ids)
            # elsif params[:status] == 'verify'
            #   campaign_ids = current_kol.campaign_invites.verifying.collect{|t| t.campaign_id }
            # elsif params[:status] == 'settled'
            #   campaign_ids = current_kol.campaign_invites.settled.collect{|t| t.campaign_id }
            # elsif params[:status]
            end
            # @campaigns = Campaign.where(:id => campaign_ids - hide_campaign_ids ).order('created_at  desc')
          end
          @campaign_invites = @campaign_invites.page(params[:page]).per_page(10)
          to_paginate(@campaign_invites)
          present :campaign_invites, @campaign_invites, with: API::V1::Entities::CampaignInviteEntities::Summary
        end

        get ':id/receive_task' do

        end
      end
    end
  end
end
