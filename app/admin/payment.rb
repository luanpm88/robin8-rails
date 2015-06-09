ActiveAdmin.register Payment do

  menu :priority => 4, :label => "Payment" ,:if => proc { current_admin_user.is_super_admin? }
  permit_params :user_product_id, :product_id, :discount_id, :card_last_four_digits, :card_type, :coupon, :amount, :status, :last_charge_result

end
