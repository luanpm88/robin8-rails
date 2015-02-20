class SubscriptionsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  layout false
  def new
    @package = Package.last
    @subscription = Subscription.new
  end

  def create
    BlueSnap::Shopper.new request, current_user, params
    redirect_to :back
  end

  def edit #upgrade downgrade

  end

  def update

  end

  def destroy #to cancel account

  end

end