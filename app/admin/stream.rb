ActiveAdmin.register Stream do

  permit_params :user_id , :name, :topics_raw, :blogs_raw, :sort_column, :position, :published_at, :keywords_raw, :keywords

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
