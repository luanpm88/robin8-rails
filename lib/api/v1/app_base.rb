module API
  module V1
    class AppBase < API::Application
      version 'v1', using: :path
      mount API::V1::Kols
      mount API::V1::Sessions
      mount API::V1::Phones
      mount API::V1::Tags
      mount API::V1::Campaigns
      mount API::V1::CampaignInvites
    end
  end
end
