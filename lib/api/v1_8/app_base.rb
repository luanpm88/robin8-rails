module API
  module V1_8
    class AppBase < API::Application
      version 'v1_8', using: :path
      mount API::V1_4::CampaignAnalysis
    end
  end
end
