class ReleasesController < ApplicationController
  layout 'public_pages', only: [:show]
  has_scope :by_news_room

  def index
    limit = current_user.current_user_features.press_release.map(&:max_count).inject{|sum,x| sum + x }
    limit = limit.nil? ? current_user.releases.count : limit
    releases = params[:public] ? Release.where(news_room_id: params[:id]).limit(limit) : apply_scopes(current_user.releases).limit(limit)
    unless params[:for_blast].blank?
      releases = releases#.published
    end
    set_paginate_headers Release, releases.count
    per_page = (limit < params[:per_page].to_i || params[:per_page].nil?) ? limit : params[:per_page].to_i

    render json: releases.order('created_at DESC').paginate(page: params[:page], per_page: per_page), each_serializer: ReleaseSerializer
  end

  def create
    release = current_user.releases.build release_params
    @new_logo = params[:release][:logo_url]
    @new_thumbnail = params[:release][:thumbnail]
    if release.save!
      if @new_logo
        AmazonStorageWorker.perform_async("release", release.id, @new_logo, nil, :logo_url)
        AmazonStorageWorker.perform_async("release", release.id, @new_thumbnail, nil, :thumbnail)
      end
      render json: release, serializer: ReleaseSerializer
    else
      render json: { errors: release.errors }, status: 422
    end
  end

  def show
    respond_to do |format|
      format.html {
        if request.subdomain.include?("-preview")
          subdomain = request.subdomain.gsub("-preview","")
          @news_room = PreviewNewsRoom.find_by(subdomain_name: request.subdomain) || NewsRoom.find_by(subdomain_name: subdomain)
          @preview_mode = true
        else
          @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
          @preview_mode = false
        end
        this_room = @news_room.parent_id.nil? ? @news_room : NewsRoom.find(@news_room.parent_id)
        @release = this_room.releases.friendly.find(params[:id])
      }
      format.json { render json: Release.where(id: params[:id], is_private: false).first }
    end
  end

  def extract_from_word
    doc = Docx::Document.open(params[:file].tempfile.path)
    render json: doc.paragraphs.map(&:to_html).join
  end

  def update
    ["iptc_categories", "concepts", "hashtags", "summaries",
      "boson_categories"].each do |item|
      params["release"][item] = params["release"][item].to_json
    end
    release = current_user.releases.find(params[:id])
    @old_logo = release.logo_url
    @new_logo = params[:release][:logo_url]
    @old_thumbnail = release.thumbnail
    @new_thumbnail = params[:release][:thumbnail]
    if release.update_attributes(release_params)
      if @new_logo!=@old_logo
        AmazonStorageWorker.perform_async("release", release.id, @new_logo, @old_logo, :logo_url)
        AmazonStorageWorker.perform_async("release", release.id, @new_thumbnail, @old_thumbnail, :thumbnail)
      end
      render json: release, serializer: ReleaseSerializer
    else
      render json: { errors: release.errors }, status: 422
    end
  end

  def destroy
    release = current_user.releases.find(params[:id])
    if release.logo_url
      AmazonDeleteWorker.perform_in(20.seconds, release.logo_url)
      #AmazonDeleteWorker.perform_in(20.seconds, release.thumbnail)
      puts "-"*50
      puts release.thumbnail
    end
    release.destroy
    render json: release
  end

  def img_url_exist
    result = false
    begin
      uri = URI(params[:url])
      request = Net::HTTP.new uri.host
      response = request.request_head uri.path
      if response.code.to_i  < 400 && response['content-type'].start_with?('image')
        result = true
      end
    rescue
    end
    render json: result
  end

  private

  def release_params
    params.require(:release).permit(:title, :text, :news_room_id, :is_private,
      :logo_url, :thumbnail, :concepts, :published_at, :iptc_categories,
      :summaries, :hashtags, :boson_categories,
      :characters_count, :words_count, :sentences_count,
      :paragraphs_count, :adverbs_count, :adjectives_count,
      :nouns_count, :organizations_count, :places_count, :people_count,
      :myprgenie, :accesswire, :prnewswire,
      :myprgenie_published_at, :accesswire_published_at, :prnewswire_published_at,
      attachments_attributes: [:id, :url, :attachment_type, :name, :thumbnail, :_destroy])
  end

  def ssl_configured?
    false
  end
end
