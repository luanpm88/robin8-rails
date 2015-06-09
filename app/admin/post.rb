ActiveAdmin.register Post do

  permit_params :user_id, :text, :scheduled_date, :social_networks, :performed_at, :shrinked_links

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

  form do |f|
    f.inputs "Post" do
      f.input :user
      f.input :text
      f.input :scheduled_date
      f.input :social_networks_raw, :as => :text
      f.input :performed_at
      f.input :shrinked_links
    end
    f.actions
  end

end