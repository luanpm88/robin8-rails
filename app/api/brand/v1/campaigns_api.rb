module Brand
  module V1
    class CampaignsAPI < Base

      resource :campaigns do
        
        desc 'Return a campaign by id'
        params do
          requires :id, type: Integer, desc: 'Campaign id'
        end
        route_param :id do
          get do
            present Campaign.find(params[:id])
          end
        end

      end

    end
  end
end
