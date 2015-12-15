ActiveAdmin.register Kol do

  permit_params :email, :first_name, :last_name, :mobile_number, :gender

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end


  index do
    selectable_column
    id_column
    column :email
    column :sign_in_count
    column :created_at
    column :updated_at
    column :first_name
    column :last_name
    column :location

    column :title
    column :industry
    column :mobile_number
    column :gender
    column :country
    column :amount
    column :frozen_amount
    actions
  end

  form do |f|
    f.inputs "Post" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :mobile_number
      f.input :gender
    end
    f.actions
  end

end
