module API
  module V1_7
    module Entities
      module CpsMaterials
        class Summary < Grape::Entity
          expose :id, :sku_id, :img_url, :material_url, :goods_name, :shop_id, :unit_price, :start_date, :end_date,
                 :kol_commision_wl, :category
          expose :category_label do  |material|
            CpsMaterial::Categories[material.category.to_sym]   rescue nil
          end
        end

        class Category < Grape::Entity
          expose :name do |category|
            category.to_a[0].to_s
          end
          expose :label do |category|
            category.to_a[1].to_s
          end
        end
      end
    end
  end
end
