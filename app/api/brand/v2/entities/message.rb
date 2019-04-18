module Brand
  module V2
    module Entities
      class Message < Entities::Base
        expose :id, :is_read, :title, :name, :desc, :sender
      end

    end
  end
end
