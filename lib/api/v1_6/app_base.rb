module API
  module V1_6
    class AppBase < API::Application
      version 'v1_6', using: :path
      mount API::V1_6::KolApplies
      mount API::V1_6::BigV
      mount API::V1_6::Professions
      mount API::V1_6::System
    end
  end
end
