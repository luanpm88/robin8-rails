json.array!(@contacts) do |contact|
  json.extract! contact, :id, :author_id, :first_name, :last_name, :email, :twitter_screen_name
  json.url contact_url(contact, format: :json)
end
