module API
  module V1
    module Entities
      module MessageEntities
        class Summary < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }
          expose :id, :title, :message_type, :is_read, :url, :logo_url, :sender, :item_id
          expose :desc do |message|
            message.desc || message.item_name
          end
          with_options(format_with: :iso_timestamp) do
            expose :read_at
            expose :created_at
          end
        end
      end
    end
  end
end

