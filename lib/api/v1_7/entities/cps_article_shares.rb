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
          expose :kol_id do |share|
            share.kol.id     rescue nil
          end
          expose :kol_name do |share|
            share.kol.name   rescue nil
          end
          expose :kol_avatar_url do |share|
            share.kol.avatar_url  rescue nil
          end
        end

        class Summary < ForList
          expose :share_forecast_commission, :share_settled_commission
        end
      end
    end
  end
end
