class ExportInfluencersController < ApplicationController
  before_action :authenticate_user!
  
  def create
    respond_to do |format|
      format.csv { render text: generate_csv }
    end
  end
  
  private
  
  def generate_csv
    CSV.generate do |csv|
      items.each do |item|
        csv << item
      end
    end
  end
  
  def items
    JSON.parse params['items'], symbolize_names: true
  end
end
