class RenderPitchContact
  include Sidekiq::Worker

  def perform(pitch_contact_id)
    pitch_contact = PitchesContact.find(pitch_contact_id)
    pitch_contact.unsubscribe_token = Digest::SHA1.hexdigest("#{pitch_contact.id}#{pitch_contact.pitch_id}#{pitch_contact.contact_id}")

    pitch_contact.rendered_pitch = pitch_contact.render_pitch
    pitch_contact.save!

    DeliverPitchContact.perform_async(pitch_contact.id)
  end
end
