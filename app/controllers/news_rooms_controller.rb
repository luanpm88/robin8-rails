class NewsRoomsController < ApplicationController
  layout 'public_pages', only: [:preview]
  def index
    set_paginate_headers NewsRoom, current_user.news_rooms.count
    render json: current_user.news_rooms.order('created_at DESC').paginate(page: params[:page], per_page: params[:per_page]), each_serializer: NewsRoomSerializer
  end

  def create
    @news_room = current_user.news_rooms.build news_room_params
    @new_logo = params[:news_room][:logo_url]
    if @news_room.save
      if @new_logo
        AmazonStorageWorker.perform_async("news_room", @news_room.id, @new_logo, nil, :logo_url)
      end
      render json: @news_room, serializer: NewsRoomSerializer
    else
      render json: { errors: @news_room.errors }, status: 422
    end
  end

  def show
    render json: NewsRoom.find(params[:id])
  end

  def update
    @news_room = NewsRoom.find(params[:id])
    @old_logo = @news_room.logo_url
    @new_logo = params[:news_room][:logo_url]
    if @news_room.update_attributes(news_room_params)
      if @new_logo!=@old_logo
        AmazonStorageWorker.perform_async("news_room", @news_room.id, @new_logo, @old_logo, :logo_url)
      end
      render json: @news_room, serializer: NewsRoomSerializer
    else
      render json: { errors: @news_room.errors }, status: 422
    end
  end

  def destroy
    @news_room = NewsRoom.find(params[:id])
    if @news_room.logo_url
       AmazonDeleteWorker.perform_in(20.seconds, @news_room.logo_url)
    end
    @news_room.destroy
    render json: @news_room
  end

  def preview
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
    respond_to do |format|
      format.html
      format.json { render json: @news_room }
    end
  end

private
    def news_room_params
      params.require(:news_room).permit(:user_id, :company_name, :room_type, :size, :email, :phone_number, :fax, :web_address,
        :description, :address_1, :address_2, :city, :state, :postal_code, :country, :owner_name,
        :job_title, :facebook_link, :twitter_link, :linkedin_link, :instagram_link, :tags, :subdomain_name, :logo_url,
        :toll_free_number, :publish_on_website, attachments_attributes: [:id, :url, :attachment_type, :_destroy],
        industry_ids: [])
    end
end
