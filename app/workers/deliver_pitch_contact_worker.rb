class DeliverPitchContact
  include Sidekiq::Worker

  def perform(pitch_contact_id) 
    pitch_contact = PitchesContact.includes([:contact]).find(pitch_contact_id)
    
    if [0, 2].include? pitch_contact.contact.origin # pressr or media_list
      ContactMailer.deliver_pitch(pitch_contact.id).deliver
    elsif pitch_contact.contact.origin == 1 # twtrland
      pitch_contact.pitch.user.twitter_post(pitch_contact.rendered_pitch)
    else
      raise "Contact origin is not between [0, 1, 2]"
    end
    pitch_contact.sent_at = Time.now.utc
    pitch_contact.save!
  end
end
