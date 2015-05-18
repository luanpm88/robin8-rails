ActiveAdmin.register Post do

  permit_params :user_id, :text, :scheduled_date, :social_networks, :performed_at, :shrinked_links
  
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
