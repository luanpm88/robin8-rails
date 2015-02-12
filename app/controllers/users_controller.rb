class UsersController < ApplicationController
  def get_current_user
    render json: current_user
  end

  def identities
    render json: current_user.identities
  end

  def disconnect_social
    @identity = current_user.identities.where(provider: params[:provider]).first
    @identity.destroy

    render json: current_user.identities
  end

end
