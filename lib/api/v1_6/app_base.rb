module API
  module V1_6
    class AppBase < API::Application
      version 'v1_6', using: :path
      mount API::V1_6::BigVApplies
      mount API::V1_6::BigV
      mount API::V1_6::My
      mount API::V1_6::System
      mount API::V1_6::Campaigns
      mount API::V1_6::CampaignInvites
    end
  end
end
