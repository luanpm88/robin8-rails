module API
  module V3_0
    module Entities
      module CreationEntities
        class BaseInfo < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }

          expose :id, :name, :description, :img_url, :user_id, :pre_kols_count, :notice, :status

          expose :status_zh do |creation|
            Creation::STATUS[creation.status.to_sym]
          end

          expose :price_range do |creation|
            creation.price_range
          end

          expose :terrace_names do |creation|
            creation.terraces.map(&:name).join('，')
          end

          expose :terrace_infos do |creation|
            API::V3_0::Entities::CreationEntities::Terrace.represent creation.terraces
          end

          expose :brand_info do |creation|
            creation.brand_info
          end

          with_options(format_with: :iso_timestamp) do
            expose :start_at
            expose :end_at
          end

          expose :trademark do |creation|
            API::V3_0::Entities::CreationEntities::Trademark.represent creation.trademark
          end
        end

        class Detail < Grape::Entity
          expose :base_info do |creation|
            API::V3_0::Entities::CreationEntities::BaseInfo.represent creation
          end

          expose :selected_kols do |creation|
            API::V3_0::Entities::CreationEntities::SelectedKol.represent creation.creation_selected_kols.is_quoted
          end

        end

        class Trademark < Grape::Entity
          expose :id, :name, :description
        end

        class SelectedKol < Grape::Entity
          expose :kol_id, :plateform_name, :plateform_uuid, :name, :avatar_url, :desc, :quoted

          expose :tenders do |selected_kol|
            API::V3_0::Entities::CreationEntities::Tender.represent selected_kol.tenders
          end
        end

        class Tender < Grape::Entity
          expose :id, :kol_id, :creation_id, :from_terrace, :price, :title, :link, :image_url, :description
        end

        class Terrace < Grape::Entity
          expose :id, :name, :short_name, :avatar
        end

      end
    end
  end
end
