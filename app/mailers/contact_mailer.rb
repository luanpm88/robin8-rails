class ContactMailer < ApplicationMailer
  def deliver_pitch(pitch_contact_id)

    @pitch_contact = PitchesContact.includes([:pitch, :contact]).find(pitch_contact_id)
    headers['X-Mailgun-Campaign-Id'] = @pitch_contact.pitch.release.news_room.campaign_name
    headers['X-Mailgun-Campaign-Id'] = @pitch_contact.pitch.release.campaign_name

    mail to: @pitch_contact.contact.email, 
      from: "#{@pitch_contact.pitch.user.full_name} <#{@pitch_contact.pitch.email_address}>",
      subject: @pitch_contact.pitch.email_subject
  end
  
  def deliver_test_pitch(test_email_id)
    @test_email = TestEmail.find(test_email_id)
    @draft_pitch = @test_email.draft_pitch
    @user = @draft_pitch.release.user
    
    mail to: @test_email.emails,
      from: "#{@user.full_name} <#{@draft_pitch.email_address}>",
      subject: "<<< Test >>> #{@draft_pitch.email_subject}"
  end
  
  def share_by_email(params)
    @params = params
    mail to: params[:reciever], from: params[:sender],
      subject: params[:subject]
  end
end
