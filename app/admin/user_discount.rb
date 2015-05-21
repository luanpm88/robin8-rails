ActiveAdmin.register UserDiscount do

  permit_params :user_id, :discount_id, :is_used

end
