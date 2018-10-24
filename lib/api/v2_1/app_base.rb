module API
  module V2_1
    class AppBase < API::Application
      version 'v2_1', using: :path
      mount API::V2_1::BaseInfos
      mount API::V2_1::Kols
    end
  end
end
