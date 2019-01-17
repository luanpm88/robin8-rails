module API
  module V3_0
    module Entities
      module CreationEntities
        class BaseInfo < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }

          expose :id, :name, :description, :img_url, :user_id

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
            API::V3_0::Entities::CreationEntities::SelectedKol.represent creation.creation_selected_kols
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

      end
    end
  end
end
