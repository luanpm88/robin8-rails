class PreviewNewsRoomsController < ApplicationController
  layout 'public_pages', only: [:preview, :presskit, :follow]

  def create
    @news_room = PreviewNewsRoom.where(parent_id: params[:preview_news_room][:parent_id]).first_or_create
    parent_news_room = NewsRoom.find(params[:preview_news_room][:parent_id])
    old_logo = @news_room.logo_url

    @news_room.assign_attributes preview_news_room_params
    if @news_room.save
      if old_logo && old_logo != parent_news_room.logo_url
        AmazonDeleteWorker.perform_in(20.seconds, old_logo)
      end
      render json: @news_room
    else
      render json: { errors: @news_room.errors }, status: 422
    end
  end

  def destroy
    @news_room = PreviewNewsRoom.find(params[:id])
    if @news_room.logo_url
      AmazonDeleteWorker.perform_in(20.seconds, @news_room.logo_url)
    end
    @news_room.destroy
    render json: @news_room
  end

private
  def preview_news_room_params
    params.require(:preview_news_room).permit(:user_id, :company_name, :room_type, :size, :email, :phone_number, :fax, :web_address,
      :description, :address_1, :address_2, :city, :state, :postal_code, :country, :owner_name,
      :job_title, :facebook_link, :twitter_link, :linkedin_link, :instagram_link, :tags, :subdomain_name, :logo_url,
      :toll_free_number, :publish_on_website, :parent_id, attachments_attributes: [:id, :url, :attachment_type, :name, :thumbnail, :_destroy])
  end
end