ActiveAdmin.register Article do

  permit_params :id, :text, :created_at, :campaign_id, :kol_id, :updated_at

end
