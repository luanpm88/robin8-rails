class TextapiController < ApplicationController
  before_action :set_client
  
  def classify
    response = @client.classify text: text_param
    
    respond_to do |format|
      format.json { render json: response[:categories]}
    end
  end

  def concepts
    response = @client.concepts text: text_param
    
    respond_to do |format|
      format.json { render json: response[:concepts]}
    end
  end

  def summarize
    response = @client.summarize title: title_param, text: text_param
    
    respond_to do |format|
      format.json { render json: response[:sentences]}
    end
  end

  def extract
    response = @client.extract url: params[:url]

    respond_to do |format|
      format.json { render json: response }
    end
  end
  
  def hashtags
    response = @client.hashtags text: text_param

    respond_to do |format|
      format.json { render json: response[:hashtags] }
    end
  end
  
  private
  def set_client
    @client = AylienTextApi::Client.new
  end
  
  def title_param
    ActionController::Base.helpers.strip_tags(params[:title])
  end
  
  def text_param
    ActionController::Base.helpers.strip_tags(params[:text])
  end
end
