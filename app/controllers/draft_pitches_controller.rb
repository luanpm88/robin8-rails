class DraftPitchesController < InheritedResources::Base
  before_action :authenticate_user!
  before_action :set_draft_pitch, only: [:show, :edit, :update, :destroy]
  
  def index
    @draft_pitches = current_user.releases.find(params[:release_id]).draft_pitches
    
    respond_to do |format|
      format.json
    end
  end
  
  def create
    @draft_pitch = DraftPitch.new(draft_pitch_params)

    respond_to do |format|
      if @draft_pitch.save
        format.json { render :show, status: :created, location: @draft_pitch }
      else
        format.json { render json: @draft_pitch.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @draft_pitch.update(draft_pitch_params)
        format.json { render :show, status: :ok, location: @draft_pitch }
      else
        format.json { render json: @draft_pitch.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @draft_pitch.destroy
    
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
  private

    def draft_pitch_params
      params.require(:draft_pitch).permit(:twitter_pitch, :email_pitch, 
        :summary_length, :email_address, :release_id, :email_subject)
    end
    
    def set_draft_pitch
      @draft_pitch = current_user.releases.find(params[:release_id])
        .draft_pitches.find(params[:id])
    end
end

