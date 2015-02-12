class NewsRoomsController < ApplicationController
  def index
    set_paginate_headers NewsRoom, current_user.news_rooms.count
    render json: current_user.news_rooms.order('created_at DESC').paginate(page: params[:page], per_page: params[:per_page])
  end

  def create
  end

  def show
  end

  def update
  end

  def destroy
  end
end
