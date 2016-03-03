
Dir["#{Rails.root}/lib/api/v2/entities/*.rb"].each { |file| require file }
module API
  module V1
    class AppBase < API::Application
      version 'v2', using: :path
      mount API::V1::Sessions
    end
  end
end
