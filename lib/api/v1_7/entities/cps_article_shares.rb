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
          expose :kol_id do
            kol.id
          end
          expose :kol_name do
            kol.name
          end
          expose :kol_avatar_url do
            kol.avatar_url
          end
        end

        class Summary < ForList
          expose :share_forecast_commission, :share_settled_commission
        end
      end
    end
  end
end
