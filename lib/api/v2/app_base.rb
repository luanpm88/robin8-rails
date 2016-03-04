
# Dir["#{Rails.root}/lib/api/v2/entities/*.rb"].each { |file| require file }
module API
  module V2
    class AppBase < API::Application
      version 'v2', using: :path
      mount API::V2::Phones
    end
  end
end
