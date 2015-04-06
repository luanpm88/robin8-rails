class PublicNewsRoomsController < ApplicationController
  layout 'public_pages'

  def show
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain) || PreviewNewsRoom.find_by(subdomain_name: request.subdomain)
    if @news_room.parent_id.nil?
      @parent_room = @news_room 
      @preview_mode = false
    else 
      @parent_room = NewsRoom.find(@news_room.parent_id)
      @preview_mode = true
    end
    @releases = @parent_room.releases.published.paginate(:page => params[:page], :per_page => 12)
    respond_to do |format|
      format.html
      format.json { render json: @news_room }
    end
  end

  def presskit
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
  end

end
