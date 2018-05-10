module API
  module V2_0
    class AppBase < API::Application
      version 'v2_0', using: :path
      mount API::V2_0::Kols
      mount API::V2_0::Contacts
      mount API::V2_0::Registers
      mount API::V2_0::Sessions
      mount API::V2_0::Articles
      mount API::V2_0::My
      mount API::V2_0::Tasks
    end
  end
end
