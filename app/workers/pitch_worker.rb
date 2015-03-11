class PitchWorker
  include Sidekiq::Worker

  def perform(pitch_id) 
    pitch = Pitch.includes(:pitches_contacts).find(pitch_id)
    pitch.pitches_contacts.each do |pitch_contact|
      RenderPitchContact.perform_async(pitch_contact.id)
    end
  end
end
