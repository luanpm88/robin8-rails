ActiveAdmin.register Stream do

  permit_params :user_id , :name, :topics_raw, :blogs_raw, :sort_column, :position, :published_at, :keywords_raw, :keywords

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

  form do |f|
    f.inputs "Stream" do
      f.input :user
      f.input :name
      f.input :topics_raw, :as => :text
      f.input :blogs_raw, :as => :text
      f.input :sort_column, :as => :select, :collection => ["published_at", "shares_count"]
      f.input :position
      f.input :published_at
      f.input :keywords_raw, :as => :text
    end
    f.actions
  end

end