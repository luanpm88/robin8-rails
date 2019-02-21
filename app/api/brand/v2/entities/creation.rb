module Brand
  module V2
    module Entities
      class Creation < Entities::Base
        format_with(:iso_timestamp) { |dt| dt.strftime('%F')}
        expose :id, :name, :description, :img_url, :pre_kols_count, :pre_amount, :notice, :status, :start_at, :end_at,
          :trademark_id

        with_options(format_with: :iso_timestamp) do
          expose :start_at, :end_at
        end

        expose :targets_hash do |object|
          object.targets_hash.all
        end

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

        expose :status_zh do |object, opts|
          ::Creation::STATUS[object.status.to_sym]
        end

        # 已招募人数
        expose :quote_count do |object|
          object.creation_selected_kols.cooperation.count
        end

        # 已消耗金额
        expose :actual_amount do |object|
          object.tenders.brand_paid.map(&:amount).sum
        end
      end
    end
  end
end