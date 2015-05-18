ActiveAdmin.register Product do

  menu :priority => 4, :label => "Products" ,:if => proc { current_admin_user.is_super_admin? }

  permit_params :slug, :is_active, :price, :status, :interval ,:name, :sku_id, :description, :is_package

  form do |f|
    f.inputs "Product" do
      f.input :slug
      f.input :is_active
      f.input :price
      f.input :status
      f.input :interval
      f.input :name
      f.input :sku_id
      f.input :description
      f.input :is_package
    end
    f.actions
  end

end
