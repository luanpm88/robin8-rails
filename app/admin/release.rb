ActiveAdmin.register Release do

  permit_params :user_id, :news_room_id, :title, :text, :is_private, :logo_url,
               :iptc_categories, :concepts, :summaries, :hashtags, :slug, :thumbnail

end
