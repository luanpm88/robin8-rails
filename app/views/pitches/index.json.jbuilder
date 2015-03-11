json.array!(@pitches) do |pitch|
  json.extract! pitch, :id, :user_id, :sent_at, :twitter_pitch, :email_pitch,
    :summary_length, :email_address
  json.url pitch_url(pitch, format: :json)
end
