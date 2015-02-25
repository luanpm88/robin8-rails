class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  skip_before_filter :require_active_subscription
  layout false

  #before_filter :force_ssl

  before_filter :require_package ,:only=>[:new,:create]

  def new
    @subscription = Subscription.new
  end

  def create
    errors,resp = BlueSnap::Shopper.new(request, current_user, params, @package)
    if errors.blank?
      begin
        @subscription = Subscription.create!(
            package_id: @package.id,
            user_id: current_user.id,
            shopper_id: resp[:batch_order][:shopper][:shopper_info][:shopper_id],
            recurring_amount: @package.price,
            charged_amount: @package.price,
            total_amount: @package.price,
            next_charge_date: nil # to be set by invoice generation
        )

      rescue Exception=> ex
        flash[:errors] = ["We are sorry, something is not right. Please fill in all details and try again"]
      end
    else
      flash[:errors] = errors
    end
    redirect_to :back
  end

  def edit #upgrade downgrade

  end

  def update

  end

  def destroy #to cancel account
    BlueSnap::Subscription.destroy(current_user.payments.last.subscription_id) if current_user.payments
    #add response message
    redirect_to :back
  end

  def index
    @subscription = current_user.subscription
  end


  def require_package
    @package = Package.last
  end

end