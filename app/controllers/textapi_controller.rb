class TextapiController < ApplicationController
  before_action :set_client
  
  def classify
    response = @client.classify text: ActionController::Base.helpers.strip_tags(params[:text])
    
    respond_to do |format|
      format.json { render json: response[:categories]}
    end
  end

  def concepts
    response = @client.concepts text: ActionController::Base.helpers.strip_tags(params[:text])
    
    respond_to do |format|
      format.json { render json: response[:concepts]}
    end
  end

  def summarize
    response = @client.summarize title: ActionController::Base.helpers.strip_tags(params[:title]),
      text: ActionController::Base.helpers.strip_tags(params[:text])
    
    respond_to do |format|
      format.json { render json: response[:sentences]}
    end
  end
  
  private
  def set_client
    @client = AylienTextApi::Client.new
  end
end
