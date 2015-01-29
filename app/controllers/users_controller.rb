class UsersController < ApplicationController
  def login_by_gplus
    @user = User.find_for_oauth(params[:info], current_user)
    if @user.persisted?
      sign_in @user
      render json: current_user

    else
      p 'error'
    end

  end
end
