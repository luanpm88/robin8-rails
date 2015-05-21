ActiveAdmin.register Stream do


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
    column :name
    column :topics do |my_resource|
      truncate(my_resource.topics.to_s, omision: "...", length: 40)
    end
    column :blogs do |my_resource|
      truncate(my_resource.blogs.to_s, omision: "...", length: 40)
    end
    column :sort_column
    column :position
    column :created_at
    column :updated_at
    column :published_at
    column :keywords do |my_resource|
      truncate(my_resource.keywords.to_s, omision: "...", length: 40)
    end
  end

end
