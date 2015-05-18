ActiveAdmin.register NewsRoom do


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
    column :company_name
    column :room_type
    column :size
    column :email
    column :phone_number
    column :owner_name
    column :job_title
    column :created_at
    column :updated_at
    column :default_news_room
    column :publish_on_website
    actions
  end

end
