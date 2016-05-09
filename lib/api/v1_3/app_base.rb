
# Dir["#{Rails.root}/lib/api/v2/entities/*.rb"].each { |file| require file }
module API
  module V1_3
    class AppBase < API::Application
      version 'v1_3', using: :path
      mount API::V1_3::Profiles
    end
  end
end
