module Brand
  module V2
    module Entities
      class Creation < Entities::Base
        expose :id, :name, :description, :img_url, :pre_kols_count, :pre_amount, :notice

        expose :trademark_name do |object|
          object.trademark.name
        end

        expose :terraces, using: Entities::CreationsTerrace do |object, opts|
          object.creations_terraces
        end

        expose :time_range do |object|
          object.time_range
        end
 
        expose :industries do |object|
          ::Tag.where(name: object.targets_hash[:industries].split(",")).map(&:label).join('/')
        end

        expose :price_range do |object, opts|
          object.price_range
        end

        expose :selected_kols, using: Entities::CreationSelectedKol do |object, opts|
          object.creation_selected_kols
        end

        expose :status do |object, opts|
          ::Creation::STATUS[object.status.to_sym]
        end
      end
    end
  end
end
