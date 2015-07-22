require 'mailgun'
class NewsRoomsController < ApplicationController
  layout 'public_pages', only: [:preview, :presskit, :follow]
  
  def index
    limit = current_user.current_user_features.newsroom.map(&:max_count).inject{|sum,x| sum + x }
    set_paginate_headers NewsRoom, current_user.news_rooms.count
    per_page = (limit < params[:per_page].to_i || params[:per_page].nil?) ? limit : params[:per_page].to_i
    render json: current_user.news_rooms.order('created_at DESC').limit(limit).paginate(page: params[:page], per_page: per_page), each_serializer: NewsRoomSerializer
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

  def web_analytics
    @news_room = NewsRoom.find params[:news_room_id]
    sa = ServiceAccount.new
    sa.service_account_user
    results = GoogleAnalytics.results(sa.first_profile, {
      start_date: (DateTime.now - 7.days),
      end_date: DateTime.now }).for_hostname(sa.first_profile, @news_room.subdomain_name + '.' + Rails.application.secrets.host)

    collection = results.collection
    web = {
      dates: collection.map{|col| col.date},
      sessions: collection.map{|col| col.sessions},
      views: collection.map{|col| col.pageViews},
    }

    render json: { web: web }
  end

  def email_analytics
    @news_room = NewsRoom.find params[:news_room_id]
    mg_client = Mailgun::Client.new Rails.application.secrets.mailgun[:api_key]
    domain = Rails.application.secrets.mailgun[:domain]
    begin
      result = mg_client.get("#{domain}/campaigns/#{@news_room.campaign_name}/stats")
      result_on_opens = mg_client.get("#{domain}/campaigns/#{@news_room.campaign_name}/events?event=opened")
      result_on_dropped = mg_client.get("#{domain}/campaigns/#{@news_room.campaign_name}/events?event=dropped")

      r = JSON.parse(result.body)
      opens = JSON.parse(result_on_opens.body)
      dropped = JSON.parse(result_on_dropped.body)

      emails = opens.map{ |o| o['recipient'] }
      emails_dropped = dropped.map{ |o| o['recipient'] }

      query = (emails.blank? ? nil : 'emails[]=' + emails.join('&emails[]='))
      query_dropped = (emails_dropped.blank? ? nil : 'emails[]=' + emails_dropped.join('&emails[]='))
    rescue
      r = { total: { sent: 0, delivered: 0, opened: 0, dropped: 0 } }
    end

    authors = if emails.blank?
      []
    else
      uri = URI(Rails.application.secrets.robin_api_url + 'authors')
      uri.query = query

      req = Net::HTTP::Get.new(uri)
      req.basic_auth Rails.application.secrets.robin_api_user, Rails.application.secrets.robin_api_pass

      res = Net::HTTP.start(uri.hostname) {|http| http.request(req) }
      parsed_res = res.code == '200' ? JSON.parse(res.body) : {}
      parsed_res['authors']
      parsed_res_emails = parsed_res['authors'].map{ |r| r['email'] }
      emails_diff = emails - parsed_res_emails
      emails_diff.each{ |e| parsed_res['authors'].push({'email': e, 'first_name': '', last_name: ''}) }
      parsed_res['authors']
    end

    authors_dropped = if emails_dropped.blank?
      []
    else
      uri = URI(Rails.application.secrets.robin_api_url + 'authors')
      uri.query = query_dropped

      req = Net::HTTP::Get.new(uri)
      req.basic_auth Rails.application.secrets.robin_api_user, Rails.application.secrets.robin_api_pass

      res = Net::HTTP.start(uri.hostname) {|http| http.request(req) }
      parsed_res = res.code == '200' ? JSON.parse(res.body) : {}
      parsed_res['authors']
      parsed_res_emails = parsed_res['authors'].map{ |r| r['email'] }
      emails_diff = emails_dropped - parsed_res_emails
      emails_diff.each{ |e| parsed_res['authors'].push({'email': e, 'first_name': '', last_name: ''}) }
      parsed_res['authors']
    end

    render json: { mail: r, authors: authors, authors_dropped: authors_dropped }
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
  
  def ssl_configured?
    !Rails.env.development? && !['preview', 'presskit', 'follow'].include?(action_name)
  end
end
