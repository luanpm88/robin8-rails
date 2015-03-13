class PitchesContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pitches_contact, only: [:show, :edit, :update, :destroy]
  
  def index
    @pitches_contacts = current_user.pitches_contacts.all
    
    respond_to do |format|
      format.json
    end
  end
  
  def show
  end

  def create
    @pitches_contact = current_user.pitches_contacts.new(pitches_contact_params)

    respond_to do |format|
      if @pitches_contact.save
        format.json { render :show, status: :created, location: @pitches_contact }
      else
        format.json { render json: @pitches_contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pitches_contact.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pitches_contact
      @pitches_contact = current_user.pitches_contacts.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pitches_contact_params
      params.require(:pitches_contact).permit(:pitch_id, :contact_id)
    end
end
