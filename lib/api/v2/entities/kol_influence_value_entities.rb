module API
  module V2
    module Entities
      module KolInfluenceValueEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :kol_uuid, :influence_level, :name, :avatar_url
          expose :influence_score do |kol_value|
            kol_value.influence_score.to_i rescue 500
          end
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
