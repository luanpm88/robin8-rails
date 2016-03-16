module API
  module V2
    module Entities
      module KolContactEntities
        class Summary  < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :name, :mobile, :influence_score
          expose :joined do |contact|
            contact.exist
          end
        end
      end
    end
  end
end
