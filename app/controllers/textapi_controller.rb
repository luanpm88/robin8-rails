class TextapiController < ApplicationController
  before_action :authenticate_user!, :set_client
  
  def classify
    response = @client.classify text: text_param
    
    respond_to do |format|
      format.json { render json: response[:categories]}
    end
  end

  def concepts
    response = @client.concepts text: text_param
    
    concepts = response[:concepts]
    
    concepts = filter_concepts(concepts)
    
    respond_to do |format|
      format.json { render json: concepts}
    end
  end

  def summarize
    response = @client.summarize title: title_param, text: text_param
    
    respond_to do |format|
      format.json { render json: response[:sentences]}
    end
  end

  def extract
    response = @client.extract url: params[:url], html: params[:html]

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
  
  def filter_concepts(concepts)
    pressr_client = AylienPressrApi::Client.new
    
    response = pressr_client.interesting_terms title: title_param,
      body: text_param
      
    normalized_interesting_terms = normalize_interesting_terms(response[:interesting_terms])
    
    title_terms = normalized_interesting_terms[:title].select do |term|
      term[:score] > 10
    end
    
    body_terms = normalized_interesting_terms[:body].select do |term|
      term[:score] > 10
    end
    
    terms = (title_terms + body_terms).uniq {|a| a[:term]}
    
    concepts.select do |key, value|
      surface_forms = value[:surfaceForms].map {|s| s[:string]}
      
      r = terms.index do |int_term|
        result = surface_forms.index do |s|
          if s =~ /#{int_term[:term]}/i
            true
          else
            false
          end
        end
        
        if result.nil?
          false
        else
          true
        end
      end
      
      if r.nil?
        false
      else
        true
      end
    end
  end
  
  def normalize_interesting_terms(interesting_terms)
    interesting_terms.inject({}) do |memo, item|
      a = 0; b = 100;
      min_score = item[1].last ? item[1].last[:score] : 0
      max_score = item[1].first ? item[1].first[:score] : 0
      x_min_max = max_score - min_score
      delta_b_a = b - a
      
      memo[item[0]] = item[1].map do |term|
        term[:score] = a + ((term[:score] - min_score) * delta_b_a / x_min_max)
        term
      end
      memo
    end
  end
end
