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
    identities = {}
    current_user.identities.each do |i|
      identities["#{i.provider}"] = i
    end

    render json: identities
  end
end
