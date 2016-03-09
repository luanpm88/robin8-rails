module API
  module V1
    module Entities
      module UpgradeEntities
        class Summary < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :app_platform, :app_version, :download_url, :release_note, :force_upgrade
          with_options(format_with: :iso_timestamp) do
            expose :release_at
          end
        end
      end
    end
  end
end

