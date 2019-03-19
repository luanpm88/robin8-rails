module API
  module V3_0
    class AppBase < API::Application
      version 'v3_0', using: :path
      mount API::V3_0::Creations
      mount API::V3_0::Kols
      mount API::V3_0::CampaignInvites
    end
  end
end
