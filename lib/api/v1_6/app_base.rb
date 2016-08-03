module API
  module V1_6
    class AppBase < API::Application
      version 'v1_6', using: :path
      mount API::V1_6::BigVApplies
      mount API::V1_6::BigV
      mount API::V1_6::Professions
    end
  end
end
