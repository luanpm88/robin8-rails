module Open
  module V1
    class Root < Base
      version 'v1', using: :path

      default_error_formatter :json
      content_type :json, 'application/json'

      mount KolAPI
      mount CampaignAPI
      mount TransactionAPI
    end
  end
end
