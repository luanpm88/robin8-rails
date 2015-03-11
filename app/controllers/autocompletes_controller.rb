class AutocompletesController < ApplicationController
  before_action :authenticate_user!, :set_client
  
  def locations
    response = @client.locations_autocompletes params
    
    respond_to do |format|
      format.json { render json: response }
    end
  end
  
  def skills
    response = @client.skills_autocompletes params
    
    respond_to do |format|
      format.json { render json: response }
    end
  end
  
  private
  
  def set_client
    @client = AylienPressrApi::Client.new
  end
end
