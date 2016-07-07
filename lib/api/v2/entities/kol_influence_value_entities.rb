module API
  module V2
    module Entities
      module KolInfluenceValueEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :kol_uuid, :influence_level
          expose :name do |kol_value, options|
            if options[:kol] &&  options[:kol].name
              options[:kol].name
            else
              kol_value.name
            end
          end
          expose :avatar_url do |kol_value, options|
            if options[:kol] && options[:kol].avatar_url
              options[:kol].avatar_url
            else
              kol_value.avatar_url
            end
          end
          expose :influence_score do |kol_value|
            kol_value.influence_score.to_i rescue 500
          end
          with_options(format_with: :iso_timestamp) do
            expose :cal_time do |kol_value|
              kol_value.created_at
            end
          end
        end

        class ItemRate  < Grape::Entity
          expose :feature_rate do |value|
            value[:feature_rate] >= 0.5 ? value[:feature_rate] : 0.5      rescue 0.5
          end
          expose :active_rate do |value|
            value[:active_rate] >= 0.5 ? value[:active_rate] : 0.5        rescue 0.5
          end
          expose :campaign_rate do |value|
            value[:campaign_rate] >= 0.5 ? value[:campaign_rate] : 0.5     rescue 0.5
          end
          expose :share_rate do |value|
            value[:share_rate] >= 0.5 ? value[:share_rate] : 0.5           rescue 0.5
          end
          expose :contact_rate do |value|
            value[:contact_rate] >= 0.5 ? value[:contact_rate] : 0.5       rescue 0.5
          end
        end

        class ItemScore < Grape::Entity
          expose :feature_score do |value|
            value[:feature_score]
          end
          expose :active_score do |value|
            value[:active_score]
          end
          expose :campaign_score do |value|
            value[:campaign_score]
          end
          expose :share_score do |value|
            value[:share_score]
          end
          expose :contact_score do |value|
            value[:contact_score]
          end
        end
      end
    end
  end
end
