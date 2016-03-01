module API
  module V1
    class Upgrades < Grape::API
      resources :upgrades do
        before do
          authenticate!
        end

        params do
          requires :app_platform, type: String, values: ['Andriod', 'IOS']
          requires :app_version, type: String
        end
        get 'check' do
          had_upgrade, newest_version = AppUpgrade.check(params[:app_platform], params[:app_version])
          if had_upgrade
            present :error, 0
            present :had_upgrade, true
            present :newest_version, newest_version, with: API::V1::Entities::UpgradeEntities::Summary
          else
            present :error, 0
            present :had_upgrade, false
          end
        end

      end
    end
  end
end
