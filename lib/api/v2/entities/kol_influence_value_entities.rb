module API
  module V2
    module Entities
      module KolInfluenceValueEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :kol_uuid, :influence_score, :influence_level, :name, :avatar_url
          with_options(format_with: :iso_timestamp) do
            expose :cal_time do |kol_value|
              kol_value.created_at
            end
          end
        end
      end
    end
  end
end
