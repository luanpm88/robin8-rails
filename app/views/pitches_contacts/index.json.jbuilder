json.array!(@pitches_contact) do |pitches_contact|
  json.extract! pitches_contact, pitch_id, :contact_id
end
