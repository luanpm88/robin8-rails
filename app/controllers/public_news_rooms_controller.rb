class PublicNewsRoomsController < ApplicationController
  layout 'public_pages'

  def show
    if request.subdomain.include?("-preview")
      subdomain = request.subdomain.gsub('-preview','')
      @news_room = PreviewNewsRoom.find_by(subdomain_name: request.subdomain) || NewsRoom.find_by(subdomain_name: subdomain)
      @preview_mode = true
    else
      @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
      @preview_mode = false
    end
    @parent_room = @news_room.parent_id.nil? ? @news_room : NewsRoom.find(@news_room.parent_id)
    @releases = @parent_room.releases.published.paginate(:page => params[:page], :per_page => 12)
    if @news_room.publish_on_website || @preview_mode
      respond_to do |format|
        format.html
        format.json { render json: @news_room }
      end
    else
      not_found
    end
  end

  def presskit
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
  end

  def article
    code = params[:code] || "some string that is not in db and will raise RecordNotFound on the next line"
    @article = Article.find_by! :tracking_code => code
  end

  private

  def ssl_configured?
    false
  end
end
