class CpsPromotionOrderItem < ActiveRecord::Base
  belongs_to :cps_promotion_order

  belongs_to :cps_material, :foreign_key => 'ware_id', :primary_key => 'sku_id'
end
