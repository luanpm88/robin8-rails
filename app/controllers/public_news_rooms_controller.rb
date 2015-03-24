class PublicNewsRoomsController < ApplicationController
  layout 'public_pages'

  def show
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
    @releases = @news_room.releases.published.paginate(:page => params[:page], :per_page => 6)
    respond_to do |format|
      format.html
      format.json { render json: @news_room }
    end
  end

  def presskit
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
  end

end
