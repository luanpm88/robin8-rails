class UsersController < ApplicationController

  def get_current_user
    render json: current_user
  end

  def get_active_subscription
    render json: current_user.active_subscription
  end

  def new
    @user = User.new
    render :layout => "website"
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      @user.save
      @user.skip_confirmation!
      sign_in @user
      return redirect_to session[:redirect_checkout_url] if session[:redirect_checkout_url].present?
      return redirect_to :pricing if current_user.active_subscription.blank?
      return redirect_to :root
    else
      flash.now[:errors] = @user.errors.full_messages
    end
    render :new, :layout=>"website"
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
    p '!!!'
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

  private

  def user_params
    params.require(:user).permit(:first_name,:last_name,:email,:password)
  end

end
