module API
  module V3_0
    module Entities
      module CreationEntities
        class BaseInfo < Grape::Entity
          format_with(:iso_timestamp) { |dt| dt.iso8601 rescue nil }

          expose :id, :name, :description, :img_url, :user_id, :pre_kols_count, :notice, :status

          expose :status_zh do |creation, options|
            selected_kol = creation.creation_selected_kols.where(kol_id: options[:kol_id]).valid.first

            selected_kol ? CreationSelectedKol::STATUS[selected_kol.status.to_sym] : Creation::STATUS[creation.status.to_sym] 
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
            expose :start_at, :end_at
          end

          expose :trademark do |creation|
            API::V3_0::Entities::CreationEntities::Trademark.represent creation.trademark
          end
        end

        class Detail < Grape::Entity
          expose :base_info do |creation|
            API::V3_0::Entities::CreationEntities::BaseInfo.represent creation, kol_id: options[:selected_kol].try(:kol_id)
          end

          expose :selected_kols do |creation|
            API::V3_0::Entities::CreationEntities::SelectedKol.represent creation.creation_selected_kols.quoted
          end

          expose :my_tender_status do |creation, options|
            options[:selected_kol].try(:status)
          end

          expose :my_tenders do |creation, options|
            API::V3_0::Entities::CreationEntities::Tender.represent options[:selected_kol].try(:tenders)
          end

        end

        class Trademark < Grape::Entity
          expose :id, :name, :description
        end

        class SelectedKol < Grape::Entity
          expose :kol_id, :plateform_name, :plateform_uuid, :name, :avatar_url, :desc, :status

          expose :tenders do |selected_kol|
            API::V3_0::Entities::CreationEntities::Tender.represent selected_kol.tenders
          end
        end

        class Tender < Grape::Entity
          expose :id, :kol_id, :creation_id, :from_terrace, :price, :title, :link, :image_url, :description
        end

        class Terrace < Grape::Entity
          expose :id, :name, :short_name, :avatar, :address
        end

      end
    end
  end
end
