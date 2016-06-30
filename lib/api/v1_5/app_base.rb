module API
  module V1_5
    class AppBase < API::Application
      version 'v1_5', using: :path
      mount API::V1_5::Tags
      mount API::V1_5::HotItems
    end
  end
end
