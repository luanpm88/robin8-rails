class ReleasesController < ApplicationController
  has_scope :by_news_room

  def index
    releases = params[:public] ? Release.where(news_room_id: params[:id]) : apply_scopes(current_user.releases)
    set_paginate_headers Release, releases.count

    render json: releases.order('created_at DESC').paginate(page: params[:page], per_page: params[:per_page]), each_serializer: ReleaseSerializer
  end

  def create
    release = current_user.releases.build release_params
    if release.save
      render json: release, serializer: ReleaseSerializer
    else
      render json: { errors: release.errors }, status: 422
    end
  end

  def show
    render json: Release.where(id: params[:id], is_private: false).first
  end

  def update
    release = current_user.releases.find(params[:id])
    if release.update_attributes(release_params)
      render json: release, serializer: ReleaseSerializer
    else
      render json: { errors: release.errors }, status: 422
    end
  end

  def destroy
    release = current_user.releases.find(params[:id])
    release.destroy
    render json: release
  end

  private

  def release_params
    params.require(:release).permit(:title, :text, :news_room_id, :is_private, 
      :logo_url, :concepts, :iptc_categories,
      attachments_attributes: [:id, :url, :attachment_type, :name, :_destroy])
  end
end
