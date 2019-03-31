module Brand
  module V2
    module Entities
      class Terrace < Entities::Base
        expose :id, :name, :short_name, :address
        expose :avatar do |object|
          object.address
        end
        expose :name_en do |object|
          object.name_en
        end
      end
    end
  end
end
