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

        class History  < Grape::Entity
          expose :feature_rate do |history|
            history[:feature_rate] >= 0.5 ? history[:feature_rate] : 0.5
          end
          expose :active_rate do |history|
            history[:active_rate] >= 0.5 ? history[:active_rate] : 0.5
          end
          expose :campaign_rate do |history|
            history[:campaign_rate] >= 0.5 ? history[:campaign_rate] : 0.5
          end
          expose :share_rate do |history|
            history[:share_rate] >= 0.5 ? history[:share_rate] : 0.5
          end
          expose :contact_rate do |history|
            history[:contact_rate] >= 0.5 ? history[:contact_rate] : 0.5
          end
        end
      end
    end
  end
end
