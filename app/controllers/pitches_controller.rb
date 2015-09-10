class PitchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pitch, only: [:show, :edit, :update, :destroy]

  # GET /pitches
  # GET /pitches.json
  def index
    @pitches = current_user.pitches.all

    respond_to do |format|
      format.json
    end
  end

  # GET /pitches/1
  # GET /pitches/1.json
  def show
  end

  # POST /pitches
  # POST /pitches.json
  def create
    @pitch = current_user.pitches.new(pitch_params)

    respond_to do |format|
      if @pitch.valid?
        unless params['contacts'].blank?
          @pitch.contacts = Contact.bulk_find_or_create(params['contacts'],current_user.id)
        end

        if @pitch.save
          PitchWorker.perform_async(@pitch.id)
          format.json { render :show, status: :created, location: @pitch }
        else
          format.json { render json: @pitch.errors, status: :unprocessable_entity }
        end
      else
        format.json { render json: @pitch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pitches/1
  # DELETE /pitches/1.json
  def destroy
    @pitch.destroy
    respond_to do |format|
#      format.html { redirect_to pitches_url, notice: 'Pitch was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pitch
      @pitch = current_user.pitches.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pitch_params
      params.require(:pitch).permit(:twitter_pitch, :email_pitch,
        :summary_length, :email_address, :email_subject, :release_id,
        :email_targets, :twitter_targets)
    end
end
