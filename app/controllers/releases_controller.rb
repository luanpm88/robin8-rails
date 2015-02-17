class ReleasesController < ApplicationController
  has_scope :by_news_room

  def index
    p apply_scopes(current_user.releases).count
    set_paginate_headers Release, current_user.releases.count

    render json: apply_scopes(current_user.releases).order('created_at DESC').paginate(page: params[:page], per_page: params[:per_page]), each_serializer: ReleaseSerializer
  end

  def create
    release = current_user.releases.build release_params
    release.save!
    render json: release
  end

  def show
    render json: current_user.releases.find(params[:id])
  end

  def update
    release = current_user.releases.find(params[:id])
    release.update_attributes!(release_params)
    render json: release
  end

  def destroy
    release = current_user.releases.find(params[:id])
    release.destroy
    render json: release
  end

  private

  def release_params
    params.require(:release).permit(:title, :text, :news_room_id)
  end
end
