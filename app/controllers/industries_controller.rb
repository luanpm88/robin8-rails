class IndustriesController < ApplicationController
  def index
    render json: Industry.all
  end
end