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

  def author_types
    response = @client.author_types_autocompletes params
    
    respond_to do |format|
      format.json { render json: response }
    end
  end
  
  def iptc_categories
    @iptc_categories = if term_param
      IptcCategory.select(:id, :label, :level, :parent)
        .where(['label LIKE ?', "%#{params[:term]}%"])
        .order(level: :asc, parent: :asc)
        .map{|a| {id: a.id, text: a.capitalized_label} }
    else
      []
    end

    respond_to do |format|
      format.json { render json: @iptc_categories }
    end
  end

  def category
    id = params[:id]
    res = { :id => id, :text => '' }
    c = IptcCategory.find_by :id => id
    if not c.blank?
      res[:text] = c.label
    end
    render :json => res
  end

  private

  def set_client
    @client = AylienPressrApi::Client.new
  end

  def term_param
    params[:term].blank? ? nil : params[:term]
  end
end
