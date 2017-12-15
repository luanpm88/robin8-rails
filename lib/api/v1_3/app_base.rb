
# Dir["#{Rails.root}/lib/api/v2/entities/*.rb"].each { |file| require file }
module API
  module V1_3
    class AppBase < API::Application
      version 'v1_3', using: :path
      mount API::V1_3::PublicLogin
      mount API::V1_3::My
      mount API::V1_3::Tasks
      mount API::V1_3::Kols
      mount API::V1_3::Transactions
      mount API::V1_3::Withdraws
      mount API::V1_3::AnalysisIdentities
      mount API::V1_3::WeixinReport
      mount API::V1_3::WeiboReport
      mount API::V1_3::KolIdentityPrices
      mount API::V1_3::LotteryActivities
      mount API::V1_3::Images
      mount API::V1_3::System
      mount API::V1_3::CheckTasks
    end
  end
end
