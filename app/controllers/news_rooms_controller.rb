require 'mailgun'
class NewsRoomsController < ApplicationController
  layout 'public_pages', only: [:preview, :presskit, :follow]
  def index
    set_paginate_headers NewsRoom, current_user.news_rooms.count
    @news_rooms = current_user.news_rooms.order('created_at DESC')
    render json: @news_rooms.paginate(page: params[:page], per_page: params[:per_page]), each_serializer: NewsRoomSerializer
  end

  def create
    @news_room = current_user.news_rooms.build news_room_params
    @new_logo = params[:news_room][:logo_url]
    if @news_room.save
      destroy_preview(params[:id])
      if @new_logo
        AmazonStorageWorker.perform_async("news_room", @news_room.id, @new_logo, nil, :logo_url)
      end
      render json: @news_room, serializer: NewsRoomSerializer
    else
      render json: { errors: @news_room.errors }, status: 422
    end
  end

  def show
    @news_room = NewsRoom.find(params[:id])
    render json: @news_room
  end

  def update
    @news_room = NewsRoom.find(params[:id])
    @old_logo = @news_room.logo_url
    @new_logo = params[:news_room][:logo_url]
    if @news_room.update_attributes(news_room_params)
      destroy_preview(params[:id])
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

  def analytics
    @news_room = NewsRoom.find params[:news_room_id]
    sa = ServiceAccount.new
    sa.service_account_user
    results = GoogleAnalytics.results(sa.first_profile, {
      start_date: (DateTime.now - 7.days),
      end_date: DateTime.now }).for_hostname(sa.first_profile, @news_room.subdomain_name + Rails.application.secrets.host)

    mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
    domain = Rails.application.secrets.mailgun[:domain]
    begin
      result = mg_client.get("#{domain}/campaigns/#{@news_room.campaign_name}/stats")
      r = JSON.parse(result.body)
    rescue
      r = { total: { sent: 0, delivered: 0, opened: 0, dropped: 0 } }
    end

    collection = results.collection
    web = {
      dates: collection.map{|col| col.date},
      sessions: collection.map{|col| col.sessions},
      views: collection.map{|col| col.pageViews},
    }

    render json: { web: web, mail: r }
  end

private

  def destroy_preview(id)
    @preview_room = PreviewNewsRoom.find_by(parent_id: id)
    @preview_room.destroy if @preview_room
  end

  def news_room_params
    params.require(:news_room).permit(:user_id, :company_name, :room_type, :size, :email, :phone_number, :fax, :web_address,
      :description, :address_1, :address_2, :city, :state, :postal_code, :country, :owner_name,
      :job_title, :facebook_link, :twitter_link, :linkedin_link, :instagram_link, :tags, :subdomain_name, :logo_url,
      :toll_free_number, :publish_on_website, attachments_attributes: [:id, :url, :attachment_type, :name, :thumbnail, :_destroy],
      industry_ids: [])
  end
end
