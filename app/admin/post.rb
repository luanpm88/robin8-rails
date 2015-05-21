ActiveAdmin.register Post do


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
    column :text do |my_resource|
      truncate(my_resource.text, omision: "...", length: 40)
    end
    column :scheduled_date
    column :created_at
    column :updated_at
    column :social_networks
    column :performed_at
    column :shrinked_links
    actions
  end

end
