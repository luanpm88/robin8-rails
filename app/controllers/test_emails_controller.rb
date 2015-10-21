class TestEmailsController < ApplicationController
  before_action :authenticate_user!

  def show
    @test_email = TestEmail.find(params[:id])
  end

  def create
    release = current_user.releases.find(params[:release_id])
    @draft_pitch = release.draft_pitches.find(params[:draft_pitch_id])
    email_pitch = @draft_pitch.email_pitch
    email_pitch.gsub!('@[Title]', '<a href="' + release.permalink + '">' + release.title + '</a>')
    email_pitch.gsub!('@[Text]', release.text)
    email_pitch.gsub!('@[Link]', release.permalink)
    email_pitch = email_pitch.sub('@[Unsubscribe Link]', "http://#{Rails.application.secrets[:host]}/unsubscribe/?token=****************************************")
    register_text = @l.t('smart_release.pitch_step.email_panel.kols_register_href_text')
    email_pitch.gsub!('@[KolReghref]', "<a href='http://#{Rails.application.secrets[:host]}/kols/new'>#{register_text}</a>")
    @draft_pitch.email_pitch = email_pitch
    @draft_pitch.save
    @temp_pitch = current_user.pitches.build(email_pitch: email_pitch,
      email_address: @draft_pitch.email_address, release_id: @draft_pitch.release_id,
      email_subject: @draft_pitch.email_subject, email_targets: true)

    @test_email = @draft_pitch.test_emails.new(test_email_params)

    respond_to do |format|
      if @test_email.save && @temp_pitch.valid?
        DeliverTestPitchWorker.perform_async(@test_email.id)
        format.json { render :show, status: :created, location: @test_email }
      else
        format.json do
          render json: @test_email.errors.messages.merge(@temp_pitch.errors.messages),
            status: :unprocessable_entity
        end
      end
    end
  end

  private

    def test_email_params
      params.require(:test_email).permit(:draft_pitch_id, :emails)
    end
end

