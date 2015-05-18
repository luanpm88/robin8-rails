ActiveAdmin.register Release do


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
    column :title
    column :text do |my_resource|
      truncate(my_resource.text, omision: "...", length: 30)
    end
    column :created_at
    column :updated_at
    column :is_private
    column :iptc_categories
    column :concepts do |my_resource|
      truncate(my_resource.concepts, omision: "...", length: 30)
    end
    column :summaries do |my_resource|
      truncate(my_resource.summaries, omision: "...", length: 30)
    end
    column :hashtags do |my_resource|
      truncate(my_resource.hashtags, omision: "...", length: 30)
    end
    column :slug
    actions
  end

end
