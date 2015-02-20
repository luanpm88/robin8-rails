class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def new
    @package = Package.last
  end

  def create
    BlueSnap::Shopper.new request, current_user, params
    redirect_to :back
  end

  def edit

  end

  def update

  end

  def destroy

  end

end