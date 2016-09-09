module API
  module V1_7
    module Entities
      module CpsArticleShares
        class ForList < Grape::Entity
          expose :id, :share_url
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          with_options(format_with: :iso_timestamp) do
            expose :created_at
          end
          expose :kol, using: API::V1::Entities::KolEntities::InviteeSummary
        end

        class Summary < ForList
          expose :share_forecast_commission, :share_settled_commission
        end
      end
    end
  end
end
