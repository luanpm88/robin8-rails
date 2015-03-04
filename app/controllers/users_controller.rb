class UsersController < ApplicationController
  def get_current_user
    render json: current_user, serializer: UserSerializer
  end

  def delete_user
    manageable_users = User.where(invited_by_id: current_user.id)
    @user = manageable_users.find(params[:id])
    if @user.avatar_url
      AmazonDeleteWorker.perform_in(20.seconds, @user.avatar_url)
    end
    @user.destroy
    render json: manageable_users
  end

  def identities
    render json: current_user.identities
  end

  def disconnect_social
    @identity = current_user.identities.where(provider: params[:provider]).first
    @identity.destroy

    render json: current_user.identities
  end

  def manageable_users
    manageable_users = User.where(invited_by_id: current_user.id)
    render json: manageable_users
  end

end
