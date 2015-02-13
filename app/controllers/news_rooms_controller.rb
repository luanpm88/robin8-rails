class NewsRoomsController < ApplicationController
  def index
    set_paginate_headers NewsRoom, current_user.news_rooms.count
    render json: current_user.news_rooms.order('created_at DESC').paginate(page: params[:page], per_page: params[:per_page]), each_serializer: NewsRoomSerializer
  end

  def create
    @news_room = current_user.news_rooms.build news_room_params
    @news_room.save!
    render json: @news_room
  end

  def show
    render json: NewsRoom.find(params[:id])
  end

  def update
    @news_room = NewsRoom.find(params[:id])
    @news_room.update_attributes!(news_room_params)
    render json: @news_room
  end

  def destroy
    @news_room = NewsRoom.find(params[:id])
    @news_room.destroy
    render json: @news_room
  end

private
  def news_room_params
    params.require(:news_room).permit(:user_id, :company_name, :room_type, :size, :email, :phone_number, :fax, :web_address,
      :description, :address_1, :address_2, :city, :state, :postal_code, :country, :owner_name,
      :job_title, :facebook_link, :twitter_link, :linkedin_link, :instagram_link, :tags, industry_ids: [])
  end
end
