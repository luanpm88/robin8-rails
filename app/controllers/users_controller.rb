class UsersController < ApplicationController
  def login_by_social
    @user = User.find_for_oauth(params[:info], current_user)
    if @user.persisted?
      sign_in @user
      render json: current_user
    else
      p 'error'
    end

  end

  def identities
    render json: current_user.identities
  end

  def connect_social
    @identity = Identity.find_for_oauth(params[:info])
    if @identity.user != current_user
      @identity.user = current_user
      @identity.save
    end

    render json: current_user.identities
  end

  def disconnect_social
    @identity = current_user.identities.where(provider: params[:provider]).first
    @identity.destroy

    render json: current_user.identities
  end

end
