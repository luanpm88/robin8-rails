module API
  module V1
    class CampaignInvites < Grape::API
      resources :campaigns do
        before do
          authenticate!
        end

        params do
          requires :status, type: String, values: ['all', 'running', 'approved' ,'verifying', 'settled', 'liked']
        end
        get 'list' do
          if params[:status] == 'like'
            like_campaign_ids = current_user.like_campaigns.collect{|t| t.campaign_id }
            @campaign_invites = current_kol.campaign_invites.where(:campaign_id => like_campaign_ids )
          else
            hide_campaign_ids = current_kol.hide_campaigns.collect{|t| t.campaign_id }
            if params[:status] == 'all'
              @campaign_invites = current_kol.campaign_invites.where.not(:campaign_id => hide_campaign_ids)
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


        end

        get ':id/receive_task'


        end
      end
    end
  end
end
