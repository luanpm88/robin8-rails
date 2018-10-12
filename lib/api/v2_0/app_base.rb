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
      mount API::V2_0::Announcements
      mount API::V2_0::Promotions
      mount API::V2_0::Credits
      mount API::V2_0::EWallets
    end
  end
end
