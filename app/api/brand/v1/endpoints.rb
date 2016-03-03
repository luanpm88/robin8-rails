module Brand
  module V1
    class Endpoints < Base
      version 'v1', using: :path

      # helpers
      #
      helpers APIHelpers

      # representations
      #
      represent Campaign, with: Entities::Campaign

      # namespaces
      #
      namespace 'user', desc: 'Operations about current user' do
        mount UserAPI
      end

      mount CampaignsAPI
    end
  end
end
