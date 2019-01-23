module Brand
  module V2
    module Entities
      class Creation < Entities::Base
        expose :name
        expose :description
        expose :trademark_name do |object, opts|
          (Trademark.find_by_id(object.trademark_id)).try(:name)
        end
        expose :terraces, using: Entities::CreationsTerrace do |object, opts|
          object.creations_terraces
        end
        expose :img_url
        expose :start_at do |object, opts|
          object.start_at.strftime('%Y-%m-%d %H:%M') if object.start_at
        end
        expose :end_at do |object, opts|
          object.end_at.strftime('%Y-%m-%d %H:%M') if object.end_at
        end
        expose :pre_kols_count
        expose :pre_amount
        expose :notice
        expose :industries do |object, opts|
          object.targets_hash[:industries].split(",").join("/")
        end
        expose :price_from do |object, opts|
          object.targets_hash[:price_from]
        end
        expose :price_to do |object, opts|
          object.targets_hash[:price_to]
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
