require 'mailgun'
class DeliverPitchContact
  include Sidekiq::Worker

  def perform(pitch_contact_id) 
    pitch_contact = PitchesContact.includes([:contact]).find(pitch_contact_id)
    
    if [0, 2].include? pitch_contact.contact.origin # pressr or media_list
      # ContactMailer.deliver_pitch(pitch_contact.id).deliver
      message_params = {
        to: pitch_contact.contact.email,
        from: "Robin8 <no-reply@robin8.com>",
        subject: pitch_contact.pitch.email_subject,
        text: pitch_contact.rendered_pitch,
        'o:campaign' => pitch_contact.pitch.release.news_room.campaign_name
      }
      mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
      domain = Rails.application.secrets.mailgun[:domain]
      mg_client.send_message domain, message_params
    elsif pitch_contact.contact.origin == 1 # twtrland
      pitch_contact.pitch.user.twitter_post(pitch_contact.rendered_pitch)
    else
      raise "Contact origin is not between [0, 1, 2]"
    end
    pitch_contact.sent_at = Time.now.utc
    pitch_contact.save!
  end
end