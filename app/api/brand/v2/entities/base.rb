module Brand
  module V2
    module Entities
      class Base < Grape::Entity
        format_with(:iso_timestamp) { |dt| dt.utc.iso8601 if dt }
      end
    end
  end
end
