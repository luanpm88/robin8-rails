json.array!(@media_lists) do |media_list|
  json.extract! media_list, :id, :name, :user_id
  json.url media_list_url(media_list, format: :json)
end
