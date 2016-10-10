module API
  module V1_4
    class AppBase < API::Application
      version 'v1_4', using: :path
      mount API::V1_4::KolCampaign
      mount API::V1_4::KolBrand
      mount API::V1_4::CpiReg
    end
  end
end
