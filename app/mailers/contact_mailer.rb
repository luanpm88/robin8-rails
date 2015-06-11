class ContactMailer < ApplicationMailer
  def deliver_pitch(pitch_contact_id)
    @pitch_contact = PitchesContact.includes([:pitch, :contact]).find(pitch_contact_id)
    
    headers['X-Mailgun-Campaign-Id'] = @pitch_contact.pitch.release.news_room.campaign_name
    
    mail to: @pitch_contact.contact.email, 
      from: "#{@pitch_contact.pitch.user.full_name} <#{@pitch_contact.pitch.email_address}>",
      subject: @pitch_contact.pitch.email_subject
  end
  
  def share_by_email(params)
    @params = params
    mail to: params[:reciever], from: params[:sender],
      subject: params[:subject]
  end
end
