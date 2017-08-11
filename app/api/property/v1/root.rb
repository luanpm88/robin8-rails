module Property
  module V1
    class Root < Base
      version 'v1', using: :path

      default_error_formatter :json
      content_type :json, 'application/json'


      mount Profile
      mount Account
      mount Identity
      mount Wechat
      mount Provinces
      mount TalkingData
      mount InfluenceMetric
    end
  end
end
