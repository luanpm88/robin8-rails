class ReleasesController < ApplicationController
  layout 'public_pages', only: [:show]
  has_scope :by_news_room

  def index
    releases = params[:public] ? Release.where(news_room_id: params[:id]) : apply_scopes(current_user.releases)
    set_paginate_headers Release, releases.count

    render json: releases.order('created_at DESC').paginate(page: params[:page], per_page: params[:per_page]), each_serializer: ReleaseSerializer
  end

  def create
    release = current_user.releases.build release_params
    @new_logo = params[:release][:logo_url]
    if release.save
      if @new_logo
        AmazonStorageWorker.perform_async("release", release.id, @new_logo, nil, :logo_url)
      end
      render json: release, serializer: ReleaseSerializer
    else
      render json: { errors: release.errors }, status: 422
    end
  end

  def show
    respond_to do |format|
      format.html {
        @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
        @release = @news_room.releases.friendly.find(params[:id])
      }
      format.json { render json: Release.where(id: params[:id], is_private: false).first }
    end
  end

  def update
    release = current_user.releases.find(params[:id])
    @old_logo = release.logo_url
    @new_logo = params[:release][:logo_url]
    if release.update_attributes(release_params)
      if @new_logo!=@old_logo
        AmazonStorageWorker.perform_async("release", release.id, @new_logo, @old_logo, :logo_url)
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
    end
    release.destroy
    render json: release
  end

  private

  def release_params
    params.require(:release).permit(:title, :text, :news_room_id, :is_private, 
      :logo_url, :concepts, :iptc_categories, :summaries, :hashtags,
      :characters_count, :words_count, :sentences_count,
      :paragraphs_count, :adverbs_count, :adjectives_count,
      :nouns_count, :organizations_count, :places_count, :people_count,
      attachments_attributes: [:id, :url, :attachment_type, :name, :thumbnail, :_destroy])
  end
end
