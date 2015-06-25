class TestEmailsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @test_email = TestEmail.find(params[:id])
  end

  def create
    @draft_pitch = current_user.releases.find(params[:release_id])
      .draft_pitches.find(params[:draft_pitch_id])
    @temp_pitch = current_user.pitches.build(email_pitch: @draft_pitch.email_pitch,
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

