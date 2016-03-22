
# Dir["#{Rails.root}/lib/api/v2/entities/*.rb"].each { |file| require file }
module API
  module V2
    class AppBase < API::Application
      version 'v2', using: :path
      mount API::V2::Phones
      mount API::V2::Influences
      mount API::V2::Articles
      mount API::V2::ArticleActions
      # mount API::V2::Kols
      mount API::V2::Sessions
      mount API::V2::Upgrades
      mount API::V2::Notify
      mount API::V2::Messages
    end
  end
end
