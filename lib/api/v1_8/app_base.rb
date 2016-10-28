module API
  module V1_8
    class AppBase < API::Application
      version 'v1_8', using: :path
      mount API::V1_8::CampaignAnalysis
      mount API::V1_8::CampaignEvaluations
    end
  end
end
