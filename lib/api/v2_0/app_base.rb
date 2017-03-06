module API
  module V2_0
    class AppBase < API::Application
      version 'v2_0', using: :path
      mount API::V2_0::Kols
    end
  end
end
