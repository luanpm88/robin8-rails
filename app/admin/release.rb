ActiveAdmin.register Release do

  permit_params :user_id, :news_room_id, :title, :text, :is_private, :logo_url,
               :iptc_categories, :concepts, :summaries, :hashtags, :slug, :thumbnail
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
      truncate(my_resource.concepts, omision: "...", length: 25)
    end
    column :summaries do |my_resource|
      truncate(my_resource.summaries, omision: "...", length: 25)
    end
    column :hashtags do |my_resource|
      truncate(my_resource.hashtags, omision: "...", length: 25)
    end
    column :slug
    actions
  end

end